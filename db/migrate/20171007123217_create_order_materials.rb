class CreateOrderMaterials < ActiveRecord::Migration[4.2][5.0]
  def change
    create_table :order_materials do |t|
      t.references :order
      t.references :material
      t.string :order_quantity, null:false,default:0
      t.float :calculated_quantity
      #order_quantityもcalculated_quantityも単位はレシピ単位で保存している
      t.string :order_material_memo
      t.date :delivery_date
      t.text :menu_name
      t.boolean :un_order_flag,default:false,null:false,index:true
      t.integer :status,default:0,null:false
      t.timestamps
    end
  end
end
