class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string :name
      t.string :delivery_slip_name
      t.integer :calculated_value
      t.string :calculated_unit
      t.integer :calculated_price
      t.float :cost_price
      t.string :cost_unit
      t.string :category
      t.string :vendor
      t.integer :code
      t.text :memo
      t.string :status

      t.timestamps null: false
    end
  end
end
