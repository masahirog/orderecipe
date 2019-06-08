class AddRowOrderToProductMenus < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :product_menus, :row_order, :integer
  end
end
