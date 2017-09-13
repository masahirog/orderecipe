class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.string :name
      t.text :recipe
      t.string :category
      t.text :serving_memo
      t.float :cost_price
      t.timestamps null: false
    end
  end
end
