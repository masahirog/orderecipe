class CreateShiftPatterns < ActiveRecord::Migration[5.2]
  def change
    create_table :shift_patterns do |t|
      t.string :pattern_name
      t.timestamps
    end
  end
end
