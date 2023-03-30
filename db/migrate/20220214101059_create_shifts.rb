class CreateShifts < ActiveRecord::Migration[5.2]
  def change
    create_table :shifts do |t|
      t.date :date
      t.integer :store_id
      t.integer :staff_id
      t.integer :shift_pattern_id
      t.integer :fix_shift_pattern_id
      t.text :memo
      t.timestamps
      t.boolean :fixed_flag,null:false,default:false
    end
  end
end
