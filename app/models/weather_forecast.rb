class WeatherForecast
  attr_reader :current_temp, :min_temp, :max_temp, :extended_forecast, :cached

  def initialize(current_temp:, min_temp:, max_temp:, extended_forecast: [], cached: false)
    @current_temp = current_temp
    @min_temp = min_temp
    @max_temp = max_temp
    @extended_forecast = extended_forecast
    @cached = cached
  end
end
