class CreateMenus < ActiveRecord::Migration[4.2]
  def change
    create_table :menus do |t|
      t.string :name
      t.text :recipe
      t.string :category
      t.text :serving_memo
      t.float :cost_price
      t.string :food_label_name
      t.string :used_additives
      t.integer :confirm_flag, null: false, default: 0
      t.string :image
      t.timestamps null: false
    end
  end
end
