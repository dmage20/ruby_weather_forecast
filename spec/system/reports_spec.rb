require 'rails_helper'

RSpec.describe "Reports page", type: :system do
  before do
    driven_by(:rack_test)

    create_list(:search, 2, :cached, :recent, zip_code: "12345")
    create(:search, :fresh, :recent, zip_code: "67890")
    # should not be counted
    create(:search, :fresh, :old, zip_code: "12345")
  end

  it "displays recent search stats" do
    visit "/reports/searches"

    expect(page).to have_content("Total Searches: 3")
    expect(page).to have_content("Cached Searches: 2")
    expect(page).to have_content("Fresh Searches: 1")
    expect(page).to have_content("Top 3 Searched Zip Codes")
    expect(page).to have_content("12345")
  end
end
