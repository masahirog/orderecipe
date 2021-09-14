class CreateAnalysisProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :analysis_products do |t|
      t.integer :analysis_id
      t.integer :smaregi_shohin_id
      t.string :smaregi_shohin_name
      t.integer :smaregi_shohintanka
      t.integer :product_id
      t.integer :orderecipe_sell_price
      t.float :cost_price
      t.integer :list_price
      t.integer :manufacturing_number
      t.integer :carry_over
      t.integer :actual_inventory
      t.integer :sales_number
      t.integer :loss_number
      t.integer :total_sales_amount
      t.integer :loss_amount
      t.timestamps
      t.float :early_sales_rate_of_all
    end
  end
end
