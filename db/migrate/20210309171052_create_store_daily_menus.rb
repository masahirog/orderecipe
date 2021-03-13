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
    end
  end
end
