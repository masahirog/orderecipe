class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.integer :menu_id
      t.string :name
      t.text :recipe

      t.timestamps null: false
    end
  end
end
