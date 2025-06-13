require 'rails_helper'

RSpec.describe GeocodingApiService do
  let(:address) { '2001 Allston Way, Berkeley, CA' }

  describe '#fetch_location_details' do
    it 'returns latitude and longitude for a valid address', :vcr do
      service = GeocodingApiService.new(address)

      result = service.fetch_location_details

      expect(result).to include(:lat, :lon)
    end

    it 'returns nil for an invalid address', :vcr do
      service = GeocodingApiService.new("!@#")
      expect(Rails.logger).to receive(:warn).with(/Geocoding API error/)
      result = service.fetch_location_details
      expect(result).to be_nil
    end
  end
end
