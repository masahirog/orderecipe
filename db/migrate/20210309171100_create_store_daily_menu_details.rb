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
      t.integer :add_stocked, default: 0, null: false
      t.integer :use_stock, default: 0, null: false
      t.integer :actual_inventory, default: 0, null: false
      t.boolean :sold_out_flag, null: false, default: false
    end
  end
end
