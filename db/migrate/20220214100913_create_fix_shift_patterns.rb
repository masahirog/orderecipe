class CreateFixShiftPatterns < ActiveRecord::Migration[5.2]
  def change
    create_table :fix_shift_patterns do |t|
      t.string :pattern_name
      t.timestamps
      t.float :working_hour
      t.time :start_time
      t.time :end_time
      t.integer :group_id
      t.string :color_code,default:"#000000"
      t.string :bg_color_code,default:"#ffffff"
      t.boolean :unused_flag,null:false,default:false
    end
  end
end
