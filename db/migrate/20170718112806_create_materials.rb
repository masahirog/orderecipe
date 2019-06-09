class CreateMaterials < ActiveRecord::Migration[4.2]
  def change
    create_table :materials do |t|
      t.string :name
      t.string :order_name
      t.string :calculated_value
      t.string :calculated_unit
      t.float :calculated_price
      t.float :cost_price
      t.string :category
      t.string :order_code
      t.text :memo
      t.integer :end_of_sales
      t.integer :vendor_id
      t.string :order_unit
      t.string :order_unit_quantity
      t.text :allergy, array: true
      t.integer :vegetable_flag, null: false, default: 0
      t.boolean :vendor_stock_flag, :null => false, :default => true
      t.integer :delivery_deadline, :null => false, :default => 1
      t.integer :storage_location_id,null:false
      t.timestamps null: false
    end
  end
end
