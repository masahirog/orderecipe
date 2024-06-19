class CreateSalesReportStaffs < ActiveRecord::Migration[6.0]
  def change
    create_table :sales_report_staffs do |t|
      t.references :sales_report,null:false
      t.references :staff,null:false
      t.integer :smile
      t.integer :eyecontact
      t.integer :voice_volume
      t.integer :talk_speed
      t.integer :speed
      t.integer :total
      t.text :memo
      t.timestamps
      t.integer :tasting
    end
  end
end
