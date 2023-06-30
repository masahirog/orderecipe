class CreateFixShiftPatternStores < ActiveRecord::Migration[6.0]
  def change
    create_table :fix_shift_pattern_stores do |t|
    	t.integer :fix_shift_pattern_id,null:false
    	t.integer :store_id,null:false
      t.timestamps
    end
		add_index :fix_shift_pattern_stores, [:fix_shift_pattern_id,:store_id], unique: true,name: 'index_uniq'
  end
end
