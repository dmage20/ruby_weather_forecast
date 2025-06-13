require 'rails_helper'

RSpec.describe "User searches for forecast", type: :system do
  before do
    driven_by(:rack_test) # For simplicity, since we don't need JS support
  end

  it "submits a search and sees forecast results" do
    visit root_path

    fill_in "Address", with: "2001 Allston Way, Berkeley"
    click_button "Get Forecast"

    expect(page).to have_content("Weather Forecast")
    expect(page).to have_content("Temperature:")
  end

  it "shows error for blank input" do
    visit root_path
    click_button "Get Forecast"

    expect(page).to have_content("Address can't be blank.")
  end
end
