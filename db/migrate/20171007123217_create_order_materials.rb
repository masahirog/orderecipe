class CreateOrderMaterials < ActiveRecord::Migration[4.2][5.0]
  def change
    create_table :order_materials do |t|
      t.integer :order_id, null:false
      t.integer :material_id, null:false
      t.string :order_quantity, null:false,default:0
      t.float :calculated_quantity
      t.string :order_material_memo
      t.date :delivery_date
      t.string :menu_name
      t.string :recipe_unit
      t.string :order_unit
      t.boolean :un_order_flag,default:false,null:false
      t.timestamps
    end
  end
end
