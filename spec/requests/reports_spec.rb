require 'rails_helper'

RSpec.describe "Reports", type: :request do
  describe "GET /reports/searches" do
    before do
      create_list(:search, 2, :cached, :recent, zip_code: "12345")
      create(:search, :fresh, :recent, zip_code: "67890")
      create(:search, :fresh, :old, zip_code: "12345")
    end

    it "returns successful response" do
      get "/reports/searches"
      expect(response).to be_successful
    end

    it "assigns correct counts and top zip codes" do
      get "/reports/searches"

      html = Nokogiri::HTML(response.body)

      expect(html.text).to include("Total Searches")
      expect(html.text).to include("3")
      expect(html.text).to include("12345 — 2 searches")
      expect(html.text).to include("67890 — 1 searches")
      expect(html.text).to include("Fresh Searches")
      expect(html.text).to include("1")
    end
  end
end
