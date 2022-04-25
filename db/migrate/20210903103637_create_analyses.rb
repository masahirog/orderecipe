class CreateAnalyses < ActiveRecord::Migration[5.2]
  def change
    create_table :analyses do |t|
      t.integer :store_id
      t.date :date
      t.integer :total_sales_amount
      t.integer :loss_amount
      t.integer :labor_cost
      t.timestamps
      t.integer :transaction_count,default:0,null:false
      t.integer :fourteen_transaction_count,default:0,null:false
      t.integer :fourteen_number_sales_sozai,default:0,null:false
      t.integer :total_number_sales_sozai,default:0,null:false
      t.integer :discount_amount
      t.integer :net_sales_amount
      t.integer :tax_amount
      t.integer :ex_tax_sales_amount
      t.integer :store_sales_amount
      t.integer :delivery_sales_amount
      t.integer :used_point_amount
      t.integer :used_coupon_amount
      t.index [:date, :store_id], unique: true
    end
  end
end
