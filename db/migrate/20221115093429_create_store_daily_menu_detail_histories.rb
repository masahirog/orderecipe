class CreateStoreDailyMenuDetailHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :store_daily_menu_detail_histories do |t|
      t.integer :store_daily_menu_detail_id
      t.integer :number
      t.timestamps
    end
  end
end
