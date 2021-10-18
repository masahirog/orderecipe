class CreateAnalyses < ActiveRecord::Migration[5.2]
  def change
    create_table :analyses do |t|
      t.integer :store_id
      t.date :date
      t.integer :sales_amount
      t.integer :loss_amount
      t.integer :labor_cost
      t.timestamps
      t.integer :transaction_count,default:0,null:false
      t.integer :fourteen_transaction_count,default:0,null:false
      t.integer :fourteen_number_sales_sozai,default:0,null:false
      t.integer :total_number_sales_sozai,default:0,null:false
      t.index [:date, :store_id], unique: true
    end
  end
end
