class CreateShiftFrames < ActiveRecord::Migration[5.2]
  def change
    create_table :shift_frames do |t|
      t.integer :group_id
      t.string :name
      t.timestamps
    end
  end
end
