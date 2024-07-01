class CreateWeeklyReports < ActiveRecord::Migration[6.0]
  def change
    create_table :weekly_reports do |t|
      t.references :store,null:false
      t.references :staff,null:false
      t.date :date,null:false
      t.text :goal
      t.text :plan
      t.text :do
      t.text :check
      t.text :action
      t.timestamps
    end
  end
end
