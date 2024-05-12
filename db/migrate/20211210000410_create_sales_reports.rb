class CreateSalesReports < ActiveRecord::Migration[5.2]
  def change
    create_table :sales_reports do |t|
      t.integer :analysis_id,null:false
      t.integer :store_id,null:false
      t.date :date,null:false
      t.integer :staff_id,null:false
      t.text :good
      t.text :issue
      t.text :other_memo
      t.timestamps
      t.integer :cash_error
      t.text :excess_or_deficiency_number_memo
      t.time :leaving_work
      t.integer :vegetable_waste_amount,null:false,default:0
      t.float :one_pair_one_talk
      t.integer :tasting_number
    end
  end
end
