require 'json'
require 'open-uri'
require 'time'
require 'active_support'
require 'active_support/core_ext'
require './climate'

class OpenWeatherMapApiClient 
  OPENWEATHERMAP_API_BASE_URL = "http://api.openweathermap.org/data/2.5"

  def initialize(climate_display_types: nil, location: nil)
    @climate_display_types = climate_display_types
    @location = location
    @climates = []
  end

  def show_climate_help
    puts <<~"EOS"
    第1引数にデータの取得方法を選択します。
      date 日付 時間 : 指定した日時の天候情報を取得します。
      number 数 : 指定した数の天候情報を取得します。
      all : 3時間ごと5日分の天候情報を取得します。
    取得方法を選択した後は取得したい天候情報を選択します。(複数の指定も可)
      --temperature : 気温
      --weather : 天気
      --humidity : 湿度
      --clouds : 雲量
      --wind : 風速
      --pressure : 気圧
    EOS
  end

  def store_all_climates
    parse_json_to_hash_climate.each do |climate|
      @climates.push(
        Climate.new(
          climate['dt'], 
          climate['weather'][0]['main'], 
          climate['main']['humidity'], 
          climate['clouds']['all'], 
          climate['wind']['speed'], 
          climate['main']['pressure'], 
          climate['main']['temp']
        )
      )
    end
  end

  def parse_json_to_hash_climate
    JSON.parse(fetch_openweathermap_api.read)['list']
  end

  def find_climate_date(date:, hour:)
    store_all_climates
    climate_date = @climates.select { |climate| climate.formatted_date_time == Time.parse("#{date} #{hour}") }
    show_result(climate_date)
  end

  def find_climate_limit(display_limit:) 
    store_all_climates
    climate_limit = @climates.take(display_limit.to_i)
    show_result(climate_limit)
  end

  def find_climate_all
    store_all_climates
    show_result(@climates)
  end

  def fetch_openweathermap_api
    openweathermap_uri = URI("#{OPENWEATHERMAP_API_BASE_URL}/forecast?")
    openweathermap_query = { appid: "#{ENV['OPENWEATHERMAP_API_KEY']}" }
    if @location.include?('-')
      openweathermap_query[:zip] = "#{@location},JP"
    else 
      openweathermap_query[:q] = "#{@location}" 
    end   
    openweathermap_uri.query = openweathermap_query.to_param
    URI.open(openweathermap_uri)
  end

  def select_climate_type(climate)
    @climate_display_types.map do |climate_display_type| 
      case climate_display_type
      when '--weather'
        climate.formatted_weather
      when '--temperature'
        climate.formatted_pressure
      when '--humidity'
        climate.formatted_humidity
      when '--clouds'
        climate.formatted_clouds
      when '--wind'
        climate.formatted_wind
      when '--pressure'
        climate.formatted_pressure
      end
    end
  end

  def show_result(found_climates)
    found_climates.each { |climate| puts "#{climate.formatted_date_time} : #{select_climate_type(climate)}" }
  end
end

if __FILE__ == $0
  raise ArgumentError, '適切な引数を入力してください' if ARGV.size < 1

  openweathermap_api_client = 
    OpenWeatherMapApiClient.new(
      climate_display_types: ARGV.select { |option| option[0..1] == '--' },
      location: ARGV.reject { |option| option[0..1] == '--' }.last
    )
  return openweathermap_api_client.show_climate_help if ARGV[0] == 'help'
  case ARGV[0]
  when 'date'
    openweathermap_api_client.find_climate_date(date: ARGV[1], hour: ARGV[2])
  when 'number'
    openweathermap_api_client.find_climate_limit(display_limit: ARGV[1])
  when 'all'
    openweathermap_api_client.find_climate_all
  end
end