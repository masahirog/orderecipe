class CreateStoreDailyMenus < ActiveRecord::Migration[5.2]
  def change
    create_table :store_daily_menus do |t|
      t.integer :daily_menu_id
      t.integer :store_id
      t.date :start_time
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
      t.integer :foods_budget
      t.integer :vegetables_budget
      t.integer :goods_budget
    end
  end
end
