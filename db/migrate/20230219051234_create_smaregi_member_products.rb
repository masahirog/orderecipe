class CreateSmaregiMemberProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :smaregi_member_products do |t|
    	t.integer :kaiin_id
    	t.integer :product_id
    	t.integer :early_number_of_purchase
    	t.integer :total_number_of_purchase
      t.timestamps
    end
  end
end
