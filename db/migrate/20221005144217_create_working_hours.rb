class CreateWorkingHours < ActiveRecord::Migration[6.0]
  def change
    create_table :working_hours do |t|
      t.references :store
      t.references :staff
      t.date :date
      t.time :start_time
      t.time :end_time
      t.float :working_time
      t.timestamps
      t.index [:store_id,:staff_id,:date], unique: true
    end
  end
end
