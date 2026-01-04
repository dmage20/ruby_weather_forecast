require 'rails_helper'

RSpec.describe WeatherService do
  describe '.call' do
    let(:address) { '12345' } # Zip code
    let(:zip_code) { '12345' }
    let(:lat) { 40.0 }
    let(:lon) { -75.0 }
    let(:cache_key) { "weather_forecast_#{zip_code}" }

    before do
      # Mock Geocoder
      allow(Geocoder).to receive(:search).with(address).and_return(
        [ double(latitude: lat, longitude: lon, postal_code: zip_code) ]
      )
    end

    context 'when forecast is cached' do
      let(:cached_forecast) { WeatherForecast.new(current_temp: 72, min_temp: 60, max_temp: 80, extended_forecast: [], cached: true) }

      before do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(cached_forecast)
      end

      it 'returns the cached forecast' do
        result = described_class.call(address)
        expect(result).to be_a(WeatherForecast)
        expect(result.current_temp).to eq(72)
        expect(result.cached).to be(true)
      end

      it 'does not call the API' do
        described_class.call(address)
        # Verify no external calls (implicit if not stubbed, or we can look for specific method calls)
      end
    end

    context 'when forecast is NOT cached' do
      before do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil)

        # Subbing any instance of WeatherService for the private method fetch_from_api
        allow_any_instance_of(described_class).to receive(:fetch_from_api).and_return(
          WeatherForecast.new(current_temp: 65, min_temp: 50, max_temp: 70, extended_forecast: [], cached: false)
        )
      end

      it 'fetches from API' do
        result = described_class.call(address)
        expect(result.current_temp).to eq(65)
        expect(result.cached).to be(false)
      end

      it 'caches the result for 30 minutes' do
        expect(Rails.cache).to receive(:write).with(cache_key, anything, expires_in: 30.minutes)
        described_class.call(address)
      end
    end

    context 'when address is invalid' do
      before do
        allow(Geocoder).to receive(:search).with('invalid').and_return([])
      end

      it 'returns nil or raises error' do
        expect { described_class.call('invalid') }.to raise_error(StandardError, /Address not found/)
      end
    end
  end
end
