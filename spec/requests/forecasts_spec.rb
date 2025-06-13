require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  describe "GET /forecast" do
    let(:address) { "2001 Allston Way, Berkeley, CA" }
    let(:zip_code) { "94704" }
    let(:forecast_data) do
      {
        "location" => { "name" => "Berkeley" },
        "forecast" => { "forecastday" => [] },
        "current" => {
          "temp_f" => "60.0 F",
          "condition" => { "text" => "Sunny" }
        }
      }
    end

    before do
      allow_any_instance_of(GeocodingApiService).to receive(:fetch_location_details)
        .and_return({ zip_code: zip_code })

      allow_any_instance_of(WeatherApiService).to receive(:fetch_forecast)
        .and_return(forecast_data)
    end

    it "creates a Search object and fetches forecast" do
      expect {
        get "/forecast", params: { address: address }
      }.to change(Search, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Berkeley")
    end

    context "when forecast is cached" do
      before do
        allow(Rails.cache).to receive(:exist?).and_return(true)
        allow(Rails.cache).to receive(:fetch).and_return(forecast_data)
      end

      it "uses cache and skips external WeatherApiService call" do
        expect_any_instance_of(WeatherApiService).not_to receive(:fetch_forecast)

        get "/forecast", params: { address: address }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Berkeley")
      end
    end

    context "when forecast is not cached" do
      before do
        allow(Rails.cache).to receive(:exist?).and_return(false)
      end

      it "calls external WeatherApiService" do
        expect_any_instance_of(WeatherApiService).to receive(:fetch_forecast)

        get "/forecast", params: { address: address }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Berkeley")
      end
    end
  end
end
