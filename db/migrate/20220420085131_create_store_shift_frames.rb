class CreateStoreShiftFrames < ActiveRecord::Migration[5.2]
  def change
    create_table :store_shift_frames do |t|
      t.integer :store_id,null:false
      t.integer :shift_frame_id,null:false
      t.integer :default_number,default:0,null:false
      t.timestamps
      t.integer :default_working_hour,default:0,null:false
      t.index [:store_id,:shift_frame_id], unique: true
    end
  end
end
