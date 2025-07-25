class CreateAnalysisCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :analysis_categories do |t|
      t.references :analysis
      t.integer :smaregi_bumon_id
      t.integer :sales_number
      t.integer :sales_amount
      t.integer :discount_amount
      t.integer :net_sales_amount
      t.integer :ex_tax_sales_amount
      t.timestamps
      t.integer :loss_amount
      t.index [:analysis_id, :smaregi_bumon_id], unique: true
    end
  end
end
