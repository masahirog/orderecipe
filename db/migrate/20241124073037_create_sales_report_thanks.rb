class CreateSalesReportThanks < ActiveRecord::Migration[6.1]
  def change
    create_table :sales_report_thanks do |t|
      t.references :sales_report,null:false
      t.references :staff,null:false
      t.text :thanks
      t.timestamps
    end
  end
end
