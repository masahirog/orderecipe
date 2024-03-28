class CreateMaterialVendorStocks < ActiveRecord::Migration[6.0]
  def change
    create_table :material_vendor_stocks do |t|
      t.integer :material_id,null:false
      t.date :date,null:false
      t.integer :previous_end_day_stock,null:false,default:0
      t.integer :end_day_stock,null:false,default:0
      t.integer :shipping_amount,null:false,default:0
      t.integer :new_stock_amount,null:false,default:0
      t.index [:date, :material_id], unique: true
      t.timestamps
      t.integer :estimated_amount,null:false,default:0
    end
  end
end
