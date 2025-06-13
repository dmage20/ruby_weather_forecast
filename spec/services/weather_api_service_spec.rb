require 'rails_helper'

RSpec.describe WeatherApiService do
  let(:zip_code) { '90210' }

  describe '#fetch_forecast' do
    it 'returns parsed forecast data from the API', :vcr do
      service = WeatherApiService.new(zip_code)

      result = service.fetch_forecast

      expect(result).to include('forecast', 'current')
      expect(result['location']['name']).to eq('Beverly Hills')
    end

    it 'returns nil for an invalid zipcode', :vcr do
      service = WeatherApiService.new("!@#")
      expect(Rails.logger).to receive(:warn).with(/Weather API error:/)
      result = service.fetch_forecast
      expect(result).to be_nil
    end
  end
end
