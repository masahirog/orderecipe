class CreateWorkingHourWorkTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :working_hour_work_types do |t|
      t.references :working_hour,null:false
      t.references :work_type,null:false
      t.datetime :start,null:false
      t.datetime :end,null:false
      t.float :worktime,null:false,default:0
      t.text :memo
      t.timestamps
    end
  end
end
