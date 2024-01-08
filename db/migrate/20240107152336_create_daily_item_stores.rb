class CreateDailyItemStores < ActiveRecord::Migration[6.0]
  def change
    create_table :daily_item_stores do |t|
      t.integer :daily_item_id
      t.integer :store_id
      t.integer :subordinate_amount
      t.timestamps
    end
  end
end
