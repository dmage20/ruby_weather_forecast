class WeatherService
  NWS_BASE_URL = "https://api.weather.gov"

  def self.call(address)
    new(address).call
  end

  def initialize(address)
    @address = address
  end

  def call
    # Limit geocoding to US to avoid ambiguous zip codes (e.g., 33178 exists in both US and Germany)
    results = Geocoder.search(@address, params: { countrycodes: "us" })
    raise StandardError, "Address not found" if results.empty?

    location = results.first
    zip_code = location.postal_code
    raise StandardError, "Could not determine Zip Code for caching" if zip_code.blank?

    # Extract location name for display (City, State format)
    location_name = build_location_name(location)

    cache_key = "weather_forecast_#{zip_code}"

    cached = Rails.cache.read(cache_key)
    return cached if cached

    # Cache Miss - Fetch from API
    # NWS API requires coordinates rounded to 4 decimal places
    lat = location.latitude.round(4)
    lon = location.longitude.round(4)

    forecast_data = fetch_from_api(lat, lon, location_name)

    # Store in cache
    cache_version = WeatherForecast.new(
      current_temp: forecast_data.current_temp,
      min_temp: forecast_data.min_temp,
      max_temp: forecast_data.max_temp,
      extended_forecast: forecast_data.extended_forecast,
      location_name: forecast_data.location_name,
      cached: true
    )

    Rails.cache.write(cache_key, cache_version, expires_in: 30.minutes)

    forecast_data # This one has cached: false from the fetch method (implicitly)
  end

  private

  def build_location_name(location)
    # Build a human-readable location name from geocoding result
    city = location.city || location.town || location.village
    state = location.state_code || location.state

    if city && state
      "#{city}, #{state}"
    elsif city
      city
    elsif state
      state
    else
      "Unknown Location"
    end
  end

  def fetch_from_api(lat, lon, location_name)
    # 1. Get Grid Points
    conn = Faraday.new(url: NWS_BASE_URL) do |f|
      f.request :retry, max: 2, interval: 0.5
      f.headers["User-Agent"] = "RubyWeatherForecast/1.0 (Weather App)"
      f.headers["Accept"] = "application/geo+json"
      f.adapter Faraday.default_adapter
    end

    points_resp = conn.get("/points/#{lat},#{lon}")
    raise StandardError, "Weather API Error: #{points_resp.status} #{points_resp.bod}" unless points_resp.success?

    points_data = JSON.parse(points_resp.body)
    grid_id = points_data.dig("properties", "gridId")
    grid_x = points_data.dig("properties", "gridX")
    grid_y = points_data.dig("properties", "gridY")

    # 2. Get Forecast
    forecast_resp = conn.get("/gridpoints/#{grid_id}/#{grid_x},#{grid_y}/forecast")
    raise StandardError, "Weather API Forecast Error: #{forecast_resp.status}" unless forecast_resp.success?

    forecast_json = JSON.parse(forecast_resp.body)
    periods = forecast_json.dig("properties", "periods") || []

    current = periods.first || {}

    WeatherForecast.new(
      current_temp: current["temperature"],
      min_temp: nil, # Complex to calculate from just one period, leave nil or implement robust parsing later
      max_temp: nil,
      extended_forecast: periods.first(5).map { |p| { name: p["name"], temp: p["temperature"], text: p["shortForecast"] } },
      location_name: location_name,
      cached: false
    )
  end
end
