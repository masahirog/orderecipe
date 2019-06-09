class CreateProductMenus < ActiveRecord::Migration[4.2][5.0]
  def change
    create_table :product_menus do |t|
      t.integer :product_id
      t.integer :menu_id
      t.integer :row_order
      t.timestamps
    end
  end
end
