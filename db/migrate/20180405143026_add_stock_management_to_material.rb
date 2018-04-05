class AddStockManagementToMaterial < ActiveRecord::Migration[5.0]
  def change
    add_column :materials, :stock_management, :integer
  end
end
