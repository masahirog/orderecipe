class CreateProductSalesPotentials < ActiveRecord::Migration[5.2]
  def change
    create_table :product_sales_potentials do |t|
      t.integer :store_id,null:false
      t.integer :product_id,null:false
      t.integer :sales_potential,null:false,default:0
      t.timestamps
      t.index [:product_id, :store_id], unique: true
    end
  end
end
