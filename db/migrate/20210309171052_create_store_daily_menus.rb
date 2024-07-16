class CreateStoreDailyMenus < ActiveRecord::Migration[5.2]
  def change
    create_table :store_daily_menus do |t|
      t.integer :daily_menu_id,null:false
      t.integer :store_id,null:false
      t.date :start_time,null:false
      t.integer :total_num,null:false,default:0
      t.integer :weather
      t.integer :max_temperature
      t.integer :min_temperature
      t.timestamps
      t.string :opentime_showcase_photo
      t.string :showcase_photo_a
      t.string :showcase_photo_b
      t.string :signboard_photo
      t.time :opentime_showcase_photo_uploaded
      t.string :event
      t.boolean :editable_flag,default:true,null:false
      t.integer :foods_budget,null:false,default:0
      # t.integer :vegetables_budget,null:false,default:0
      t.integer :goods_budget,null:false,default:0
      t.integer :revised_foods_budget,null:false,default:0
      t.integer :revised_goods_budget,null:false,default:0
      t.integer :soup_make_num
      t.integer :fukusai_make_num
      t.integer :shusai_make_num
      t.integer :salad_make_num
      t.integer :sweets_make_num
      t.integer :curry_make_num
      t.integer :bento_make_num
    end
    add_index :store_daily_menus, [:daily_menu_id,:store_id,:start_time], unique: true, name: 'index_uniq'
  end
end
