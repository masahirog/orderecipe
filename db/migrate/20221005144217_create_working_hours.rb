class CreateWorkingHours < ActiveRecord::Migration[6.0]
  def change
    create_table :working_hours do |t|
      t.date :date
      t.string :name
      t.integer :staff_id
      t.float :working_time
      t.integer :jobcan_staff_code
      t.integer :store_id
      t.timestamps
      t.integer :group_id
      t.float :kari_working_time
      t.float :chori_of_working_time
      t.float :kiridashi_of_working_time
      t.float :moritsuke_of_working_time
      t.float :sekisai_of_working_time
      t.float :sonota_of_working_time
      t.float :tare_of_working_time
    end
  end
end
