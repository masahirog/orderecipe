class CreateStoreDailyMenuDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :store_daily_menu_details do |t|
      t.integer :store_daily_menu_id, null: false
      t.integer :product_id, null: false
      t.integer :number, default: 0, null: false
      t.float :price, default: 0, null: false
      t.integer :total_price, default: 0, null: false
      t.integer :row_order, default: 0, null: false
      t.timestamps
    end
  end
end
