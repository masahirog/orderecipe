class CreateMaterialVendorStocks < ActiveRecord::Migration[6.0]
  def change
    create_table :material_vendor_stocks do |t|
      t.integer :material_id,null:false
      t.date :date,null:false
      t.integer :previous_end_day_stock,null:false,default:0
      t.integer :end_day_stock,null:false,default:0
      t.integer :shipping_amount
      t.integer :new_stock_amount
      t.index [:date, :material_id], unique: true
      t.timestamps
      t.integer :estimated_amount
    end
  end
end
