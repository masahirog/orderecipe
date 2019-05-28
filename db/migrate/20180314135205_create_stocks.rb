class CreateStocks < ActiveRecord::Migration[5.0]
  def change
    create_table :stocks do |t|
      t.integer :material_id,null:false
      t.date :date,null:false
      t.float :start_day_stock,null:false,default:0
      t.float :end_day_stock,null:false,default:0
      t.float :used_amount,null:false,default:0
      t.float :delivery_amount,null:false,default:0
      t.boolean :inventory_flag,null:false,default:false

      t.index [:date, :material_id], unique: true

      t.timestamps
    end
  end
end
