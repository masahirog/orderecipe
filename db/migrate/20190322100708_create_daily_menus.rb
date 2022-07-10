class CreateDailyMenus < ActiveRecord::Migration[4.2][5.2]
  def change
    create_table :daily_menus do |t|
      t.date :start_time,null:false,unique: true
      t.integer :total_manufacturing_number,null:false,default:0
      t.integer :weather
      t.integer :max_temperature
      t.integer :min_temperature
      t.timestamps
      t.integer :sozai_manufacturing_number,null:false,default:0
      t.string :event
    end
  end
end
