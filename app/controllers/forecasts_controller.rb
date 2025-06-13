class ForecastsController < ApplicationController
  # This controller contains the core application logic for the weather feature.
  # It handles user input, coordinates with services (GeocodingApiService and WeatherApiService),
  # creates Search records for tracking, and manages caching using Rails.cache.
  # The use of a retry mechanism improves resilience to external API failures.
  # Caching is keyed by zip code and expires in 30 minutes. In large scale applications, a more robust
  # cache backend like Redis would be recommended.

  def new
  end

  def show
    address = forecast_params[:address]

    if address.blank?
      flash[:alert] = "Address can't be blank."
      redirect_to root_path and return
    elsif params[:address].length > 200
      redirect_to root_path, alert: "Address is too long"
    end

    location_details = with_retries(max_attempts: 3, delay: 1) do
      GeocodingApiService.new(address).fetch_location_details
    end

    if location_details.nil?
      flash[:alert] = "Unable to geocode the address."
      redirect_to root_path and return
    end

    zip_code = location_details[:zip_code] || "unknown"
    if zip_code == "unknown"
        flash[:alert] = "Could not determine zip code for that address."
        redirect_to root_path and return
    end


    cache_key = "forecast/#{zip_code}"
    @cached = Rails.cache.exist?(cache_key)

    Search.create!(
      address: address,
      zip_code: zip_code,
      searched_at: Time.current,
      cached: @cached
    )

    @forecast = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      Rails.logger.info("Fetching new forecast for #{zip_code}")
      with_retries(max_attempts: 3, delay: 1) do
        WeatherApiService.new(zip_code).fetch_forecast
      end
    end

    unless @forecast
      flash[:alert] = "Failed to retrieve forecast data."
      redirect_to root_path and return
    end
    @location = @forecast["location"]["name"]
  end

    private

  def forecast_params
    params.permit(:address)
  end

  def with_retries(max_attempts:, delay:)
    attempts = 0
    begin
      attempts += 1
      yield
    rescue StandardError => e
      Rails.logger.warn("Attempt #{attempts} failed: #{e.message}")
      sleep delay if attempts < max_attempts
      retry if attempts < max_attempts
      nil
    end
  end
end
