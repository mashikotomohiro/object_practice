class Climate
  def initialize(date_time, weather, humidity, clouds, wind, pressure, temperature)
    @date_time = date_time
    @weather = weather
    @humidity = humidity
    @clouds = clouds
    @wind = wind
    @pressure = pressure
    @temperature = temperature
  end

  def formatted_date_time
    Time.at(@date_time)
  end

  def formatted_weather
    "weather→#{@weather}"
  end

  def formatted_humidity
    "humidity→#{@humidity}%"
  end

  def formatted_clouds
    "clouds→#{@clouds}%"
  end

  def formatted_wind
    "wind→#{@wind}m"
  end

  def formatted_pressure
    "pressure→#{@pressure}hpa"
  end

  def formatted_temperature
    "temperature→#{(@temperature.to_i - 273).floor}℃"
  end
end