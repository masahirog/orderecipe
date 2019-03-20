class AddColumnsToMaterials < ActiveRecord::Migration[5.0]
  def change
    add_column :materials, :vendorstock_flag, :boolean
    # add_column :materials, :delivery_deadline, :integer, :null => false, :default => 1

  end
end
