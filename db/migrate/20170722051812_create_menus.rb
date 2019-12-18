class CreateMenus < ActiveRecord::Migration[4.2]
  def change
    create_table :menus do |t|
      t.string :name
      t.string :roma_name
      t.text :cook_the_day_before
      t.integer :category
      t.text :serving_memo
      t.float :cost_price
      t.string :food_label_name
      t.string :used_additives, null: false, default: ''
      t.boolean :confirm_flag, null: false, default: false
      t.text :cook_on_the_day
      t.string :image
      t.integer :base_menu_id
      t.timestamps null: false
    end
  end
end
