class CreateShifts < ActiveRecord::Migration[5.2]
  def change
    create_table :shifts do |t|
      t.date :date,index:true
      t.integer :store_id
      t.references :staff
      t.integer :shift_pattern_id
      t.integer :fix_shift_pattern_id
      t.text :memo
      t.timestamps
      t.boolean :fixed_flag,null:false,default:false
      t.time :start_time
      t.time :end_time
      t.time :rest_start_time
      t.time :rest_end_time
    end
  end
end
