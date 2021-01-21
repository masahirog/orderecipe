class CreateDailyMenuPhotos < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_menu_photos do |t|
      t.integer :daily_menu_id,null:false
      t.string :image
      t.timestamps
    end
  end
end
