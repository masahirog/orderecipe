class AddColumnsToMaterials < ActiveRecord::Migration[5.0]
  def change
    add_column :materials, :vendor_stock_flag, :boolean, :null => false, :default => true
    # add_column :materials, :delivery_deadline, :integer, :null => false, :default => 1

  end
end
