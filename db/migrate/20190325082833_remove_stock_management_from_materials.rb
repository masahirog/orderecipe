class RemoveStockManagementFromMaterials < ActiveRecord::Migration[4.2][5.2]
  def change
    remove_column :materials, :stock_management, :integer
  end
end

