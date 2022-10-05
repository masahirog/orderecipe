class CreateWorkingHours < ActiveRecord::Migration[6.0]
  def change
    create_table :working_hours do |t|
      t.date :date
      t.string :name
      t.float :working_time
      t.integer :jobcan_staff_code
      t.integer :store_id
      t.timestamps
    end
  end
end
