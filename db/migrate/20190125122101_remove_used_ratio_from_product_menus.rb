class RemoveUsedRatioFromProductMenus < ActiveRecord::Migration[4.2][5.0]
  def change
    remove_column :product_menus, :used_ratio, :float
  end
end

