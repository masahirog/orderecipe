class CreateProductMenus < ActiveRecord::Migration[5.0]
  def change
    create_table :product_menus do |t|
      t.integer :product_id
      t.integer :menu_id
      t.float :menu_cost_price
      t.timestamps
    end
  end
end
