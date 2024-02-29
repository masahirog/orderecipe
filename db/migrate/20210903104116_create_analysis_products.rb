class CreateAnalysisProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :analysis_products do |t|
      t.references :analysis
      t.integer :smaregi_shohin_id
      t.text :smaregi_shohin_name
      t.integer :smaregi_shohintanka
      t.integer :product_id
      t.integer :orderecipe_sell_price
      t.float :cost_price
      t.integer :manufacturing_number
      t.integer :carry_over
      t.integer :actual_inventory
      t.integer :sales_number
      t.integer :loss_number
      t.integer :total_sales_amount
      t.integer :loss_amount
      t.timestamps
      t.integer :sixteen_total_sales_number,default:0,null:false
      t.boolean :exclusion_flag,default:0,null:false
      t.float :potential
      t.integer :bumon_id
      t.integer :bumon_mei
      t.integer :discount_amount
      t.integer :net_sales_amount
      t.integer :ex_tax_sales_amount
      t.float :discount_rate
      t.boolean :loss_ignore,default:false,null:false
      t.integer :discount_number,default:0
      t.float :nomination_rate,default:0,null:false
      t.index [:analysis_id, :product_id], unique: true
    end
  end
end
