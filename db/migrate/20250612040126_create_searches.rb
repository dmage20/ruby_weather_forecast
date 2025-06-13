class CreateSearches < ActiveRecord::Migration[7.2]
  def change
    create_table :searches do |t|
      t.string :address
      t.string :zip_code
      t.datetime :searched_at

      t.timestamps
    end
  end
end
