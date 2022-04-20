class CreateFixShiftPatternShiftFrames < ActiveRecord::Migration[5.2]
  def change
    create_table :fix_shift_pattern_shift_frames do |t|
      t.integer :fix_shift_pattern_id
      t.integer :shift_frame_id
      t.timestamps
    end
  end
end
