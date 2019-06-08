class AddStockManagementToMaterial < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :materials, :stock_management, :integer
  end
end
