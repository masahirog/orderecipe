class CreateStaffStores < ActiveRecord::Migration[6.0]
  def change
    create_table :staff_stores do |t|
    	t.integer :staff_id
    	t.integer :store_id
      t.boolean :affiliation_flag,null:false,default:false
    	t.integer :transportation_expenses
      t.timestamps
    end
  end
end
