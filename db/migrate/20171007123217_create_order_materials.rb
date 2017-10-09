class CreateOrderMaterials < ActiveRecord::Migration[5.0]
  def change
    create_table :order_materials do |t|
      t.integer :order_id
      t.integer :material_id
      t.integer :order_quantity
      t.timestamps
    end
  end
end
