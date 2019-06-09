class CreateProductMenus < ActiveRecord::Migration[4.2][5.0]
  def change
    create_table :product_menus do |t|
      t.integer :product_id,null:false
      t.integer :menu_id,null:false
      t.integer :row_order,null:false,default:0
      t.timestamps
    end
  end
end
