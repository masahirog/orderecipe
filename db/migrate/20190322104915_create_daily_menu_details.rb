class CreateDailyMenuDetails < ActiveRecord::Migration[4.2][5.2]
  def change
    create_table :daily_menu_details do |t|
      t.references :daily_menu
      t.references :product
      t.integer :manufacturing_number, default: 0, null: false
      t.float :cost_price_per_product, default: 0, null: false
      t.integer :total_cost_price, default: 0, null: false
      t.integer :row_order, default: 0, null: false
      t.integer :serving_plate_id
      t.boolean :signboard_flag, default: 0, null: false
      t.boolean :window_pop_flag, default: 0, null: false
      t.time :sold_outed
      t.integer :for_single_item_number, default: 0, null: false
      t.integer :for_sub_item_number, default: 0, null: false
      t.timestamps
      t.integer :adjustments, default: 0, null: false
      t.integer :sell_price, default: 0, null: false
      t.integer :paper_menu_number
      t.index [:daily_menu_id,:paper_menu_number], unique: true
      t.boolean :change_flag, default: 0, null: false
      t.index [:daily_menu_id,:product_id], unique: true
    end
  end
end
