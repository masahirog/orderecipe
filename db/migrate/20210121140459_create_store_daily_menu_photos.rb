class CreateStoreDailyMenuPhotos < ActiveRecord::Migration[5.2]
  def change
    create_table :store_daily_menu_photos do |t|
      t.integer :store_daily_menu_id,null:false
      t.string :image
      t.timestamps
    end
  end
end
