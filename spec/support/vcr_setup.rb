require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<WEATHER_API_KEY>') { Rails.application.credentials.dig(:weather_api, :key) }
  config.allow_http_connections_when_no_cassette = true
end
