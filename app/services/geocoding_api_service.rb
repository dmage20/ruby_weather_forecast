require "httparty"

class GeocodingApiService
  # This service encapsulates the logic to retrieve location details from a user-provided address
  # by integrating with an external geocoding API. It handles making the request, parsing the response,
  # and returning structured location data for internal use. It also includes basic error handling
  # to gracefully deal with external API failures. A possible improvement could be to include retry logic
  # within this class, or to extract shared request-handling behavior into a base service class that can
  # be reused across multiple API services in the application.

  include HTTParty
  base_uri "https://nominatim.openstreetmap.org"

  def initialize(address)
    @address = address
  end

  def fetch_location_details
    response = self.class.get("/search", query: {
      q: @address,
      format: "json",
      limit: 1,
      addressdetails: 1
    }, headers: {
      "User-Agent" => "WeatherApp/1.0"
    })

    if response.success? && response.parsed_response.any?
      data = response.parsed_response.first

      {
        display_name: data["display_name"],
        town: data["town"],
        state: data["state"],
        country: data["country"],
        zip_code: data.dig("address", "postcode"),
        lat: data["lat"],
        lon: data["lon"]
      }
    else
      Rails.logger.warn("Geocoding API error: #{response.code} - #{response.body}")
      nil
    end
  rescue => e
    Rails.logger.error("Geocoding API exception: #{e.class} - #{e.message}")
    nil
  end
end
