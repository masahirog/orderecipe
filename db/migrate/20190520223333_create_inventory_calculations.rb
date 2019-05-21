class CreateInventoryCalculations < ActiveRecord::Migration[5.2]
  def change
    create_table :inventory_calculations do |t|
      t.date :date,null:false
      t.float :start_stock,null:false,default:0
      t.float :end_stock,null:false,default:0
      t.float :used_amount,null:false,default:0
      t.float :delivery_amount,null:false,default:0
      t.integer :material_id,null:false
      t.index [:date, :material_id], unique: true

      t.timestamps
    end
  end
end
