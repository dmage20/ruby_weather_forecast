class WeatherApiService
  # This service handles integration with the external WeatherAPI to retrieve forecast data
  # based on a given zip code. It encapsulates the HTTP request logic, response parsing,
  # and basic error handling. This structure allows for clear separation of concerns and
  # makes the forecast retrieval logic reusable and testable. In a production environment,
  # enhancements such as retry logic.

  include HTTParty
  base_uri "http://api.weatherapi.com/v1"

  def initialize(zip_code)
    @zip_code = zip_code
    @api_key = Rails.application.credentials.dig(:weather_api, :key)
  end

  def fetch_forecast
    response = self.class.get("/forecast.json", query: {
      key: @api_key,
      q: @zip_code,
      days: 3
    })

    if response.success? && !response.parsed_response.key?("error")
      response.parsed_response
    else
      Rails.logger.warn("Weather API error: #{response.code} - #{response.body}")
      nil
    end

  rescue => e
    Rails.logger.error("Weather API exception: #{e.class} - #{e.message}")
    nil
  end
end
