require 'rails_helper'

RSpec.describe Search, type: :model do
  describe "validations" do
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:zip_code) }
    it { should validate_presence_of(:searched_at) }
    it { should allow_value(true, false).for(:cached) }
  end

  describe "scopes" do
    let!(:recent_cached) { create(:search, :cached, :recent) }
    let!(:recent_fresh)  { create(:search, :fresh, :recent) }
    let!(:old_cached)    { create(:search, :cached, :old) }

    it "returns recent searches" do
      expect(Search.recent).to include(recent_cached, recent_fresh)
      expect(Search.recent).not_to include(old_cached)
    end

    it "returns only cached searches" do
      expect(Search.cached).to include(recent_cached, old_cached)
      expect(Search.cached).not_to include(recent_fresh)
    end

    it "returns only fresh (non-cached) searches" do
      expect(Search.fresh).to include(recent_fresh)
      expect(Search.fresh).not_to include(recent_cached, old_cached)
    end
  end
end
