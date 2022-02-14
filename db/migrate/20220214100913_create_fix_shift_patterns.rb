class CreateFixShiftPatterns < ActiveRecord::Migration[5.2]
  def change
    create_table :fix_shift_patterns do |t|
      t.integer :section
      t.string :pattern_name
      t.timestamps
    end
  end
end
