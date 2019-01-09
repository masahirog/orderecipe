class AddColumnsToMaterials < ActiveRecord::Migration[5.0]
  def change
    add_column :materials, :vendorstock_flag, :boolean
  end
end
