class CreateMaterials < ActiveRecord::Migration[4.2]
  def change
    create_table :materials do |t|
      t.string :name
      t.string :order_name
      t.integer :calculated_value
      t.string :calculated_unit
      t.integer :calculated_price
      t.float :cost_price
      t.string :category
      t.string :order_code
      t.text :memo
      t.integer :end_of_sales
      t.integer :vendor_id

      t.timestamps null: false
    end
  end
end
