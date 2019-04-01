class CreateDailyMenuDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_menu_details do |t|
      t.integer :daily_menu_id, null: false
      t.integer :product_id, null: false
      t.integer :manufacturing_number, default: 0, null: false
      t.float :cost_price_per_product, default: 0, null: false
      t.integer :total_cost_price, default: 0, null: false
      t.integer :row_order, default: 0, null: false
      t.timestamps
    end
  end
end
