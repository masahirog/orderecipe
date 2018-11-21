class AddUsedRatioToProductMenus < ActiveRecord::Migration[5.0]
  def change
    add_column :product_menus, :used_ratio, :float, null: false, default: 1
  end
end
