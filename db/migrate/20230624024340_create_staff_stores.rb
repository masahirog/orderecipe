class CreateStaffStores < ActiveRecord::Migration[6.0]
  def change
    create_table :staff_stores do |t|
    	t.integer :staff_id
    	t.integer :store_id
    	t.integer :transportation_expenses
      t.index [:staff_id,:store_id], unique: true
      t.timestamps
    end
  end
end
