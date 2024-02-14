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
      t.integer :carry_over, default: 0, null: false
      t.integer :actual_inventory, default: 0, null: false
      t.boolean :sold_out_flag, null: false, default: false
      t.integer :serving_plate_id
      t.boolean :signboard_flag, default: 0, null: false
      t.boolean :pricecard_need_flag, default: 0, null: false
      t.integer :stock_deficiency_excess, default: 0, null: false
      t.integer :sozai_number, default: 0, null: false
      t.integer :bento_fukusai_number, default: 0, null: false
      t.integer :showcase_type
      t.integer :prepared_number,default:0
      t.integer :excess_or_deficiency_number,default:0
    end
    add_index :store_daily_menu_details, [:store_daily_menu_id,:product_id], unique: true,name: 'index_uniq'
  end
end
