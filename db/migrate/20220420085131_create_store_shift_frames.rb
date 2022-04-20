class CreateStoreShiftFrames < ActiveRecord::Migration[5.2]
  def change
    create_table :store_shift_frames do |t|
      t.integer :store_id
      t.integer :shift_frame_id
      t.integer :default_number
      t.timestamps
    end
  end
end
