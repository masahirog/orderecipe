class CreateMaterials < ActiveRecord::Migration[4.2]
  def change
    create_table :materials do |t|
      t.string :name, unique: true
      t.string :order_name, unique: true
      t.float :recipe_unit_quantity
      t.string :recipe_unit
      t.float :recipe_unit_price
      t.float :cost_price
      t.integer :category
      t.string :order_code
      t.text :memo
      t.boolean :unused_flag, null: false, default: false
      t.integer :vendor_id
      t.string :order_unit
      t.float :order_unit_quantity
      t.text :allergy, array: true
      t.boolean :vegetable_flag, null: false, default: false
      t.boolean :vendor_stock_flag, :null => false, :default => true
      t.integer :delivery_deadline, :null => false, :default => 1
      t.integer :storage_location_id,null:false
      t.timestamps null: false
      t.string :accounting_unit
      t.integer :accounting_unit_quantity
    end
  end
end
