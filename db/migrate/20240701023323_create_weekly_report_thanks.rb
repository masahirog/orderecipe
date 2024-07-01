class CreateWeeklyReportThanks < ActiveRecord::Migration[6.0]
  def change
    create_table :weekly_report_thanks do |t|
      t.references :weekly_report,null:false
      t.references :staff,null:false
      t.text :thanks
      t.timestamps
    end
  end
end
