class CreateMaterialVendors < ActiveRecord::Migration[5.0]
  def change
    create_table :material_vendors do |t|
      t.integer :material_id
      t.integer :vendor_id
      t.timestamps
    end
  end
end
