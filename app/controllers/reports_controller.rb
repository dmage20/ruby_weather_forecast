class ReportsController < ApplicationController
  # This controller provides reporting functionality by aggregating data from Search records.
  # It presents summary statistics like total searches, cache usage, and top zip codes.
  # The structure is intentionally simple to demonstrate how user activity can inform product
  # and technical decisions. In a real-world application, access to these reports would be
  # restricted to admin users.

  def searches
    recent_searches = Search.recent

    @total_searches = recent_searches.count
    @cached_count = recent_searches.cached.count
    @fresh_count = recent_searches.fresh.count
    @top_zip_codes = recent_searches.group(:zip_code).order("count_id DESC").limit(3).count(:id)
  end
end
