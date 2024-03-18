class CreateWorkingHourWorkTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :working_hour_work_types do |t|
      t.references :working_hour,null:false
      t.references :work_type
      t.integer :time_frame
      t.timestamps
    end
  end
end
