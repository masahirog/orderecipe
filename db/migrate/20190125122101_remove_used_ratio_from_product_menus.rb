class RemoveUsedRatioFromProductMenus < ActiveRecord::Migration[5.0]
  def change
    remove_column :product_menus, :used_ratio, :float
  end
end
