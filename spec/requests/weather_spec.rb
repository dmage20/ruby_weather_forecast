require 'rails_helper'

RSpec.describe "Weather", type: :request do
  describe "GET /weather" do
    it "returns http success" do
      get "/weather"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Weather Forecast")
    end

    context "when address is provided" do
      let(:forecast) {
        WeatherForecast.new(
          current_temp: 70,
          min_temp: 60,
          max_temp: 80,
          extended_forecast: [ { name: 'Today', text: 'Sunny' } ],
          cached: false
        )
      }

      before do
        allow(WeatherService).to receive(:call).with('12345').and_return(forecast)
      end

      it "displays the forecast" do
        get "/weather", params: { address: '12345' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("70&deg;F")
        expect(response.body).to include("Sunny")
      end
    end

    context "when address is invalid" do
      before do
        allow(WeatherService).to receive(:call).and_raise(StandardError, "Address not found")
      end

      it "displays an error message" do
        get "/weather", params: { address: 'invalid' }
        expect(response.body).to include("Address not found")
      end
    end
  end
end
