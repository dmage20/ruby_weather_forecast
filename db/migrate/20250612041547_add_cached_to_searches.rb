class AddCachedToSearches < ActiveRecord::Migration[7.2]
  def change
    add_column :searches, :cached, :boolean
  end
end
