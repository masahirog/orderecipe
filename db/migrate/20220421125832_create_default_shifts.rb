class CreateDefaultShifts < ActiveRecord::Migration[5.2]
  def change
    create_table :default_shifts do |t|
      t.integer :weekday
      t.integer :store_id
      t.integer :staff_id
      t.integer :fix_shift_pattern_id
      t.text :memo
      t.timestamps
      t.time :start_time
      t.time :end_time
      t.time :rest_start_time
      t.time :rest_end_time
    end
  end
end
