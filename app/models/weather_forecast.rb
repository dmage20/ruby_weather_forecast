class WeatherForecast
  attr_reader :current_temp, :min_temp, :max_temp, :extended_forecast, :cached, :location_name

  def initialize(current_temp:, min_temp:, max_temp:, extended_forecast: [], cached: false, location_name: nil)
    @current_temp = current_temp
    @min_temp = min_temp
    @max_temp = max_temp
    @extended_forecast = extended_forecast
    @cached = cached
    @location_name = location_name
  end
end
