class Search < ApplicationRecord
  # This model captures search activity, recording whether results were cached.
  # These records support reporting and analysis of user behavior,
  # helping to inform product, performance, and design decisions.
  # The length of address is limited to prevent overly long strings.

  validates :address, :zip_code, :searched_at, presence: true
  validates :address, length: { maximum: 200 }

  scope :cached, -> { where(cached: true) }
  scope :fresh, -> { where(cached: false) }
  scope :recent, -> { where("searched_at >= ?", 1.week.ago) }
end
