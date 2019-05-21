class CreateStockMaterials < ActiveRecord::Migration[5.0]
  def change
    create_table :stock_materials do |t|
      t.integer :stock_id
      t.integer :material_id
      t.float :amount
      t.text :memo
      t.index [:stock_id, :material_id], unique: true

      t.timestamps
    end
  end
end
