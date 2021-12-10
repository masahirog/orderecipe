class CreateSalesReports < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_reports do |t|
      t.integer :analysis_id,null:false
      t.integer :store_id,null:false
      t.date :date,null:false
      t.integer :staff_id,null:false
      t.integer :sales_amount
      t.integer :sales_count
      t.text :good
      t.text :issue
      t.text :other_memo
      t.timestamps
    end
  end
end
