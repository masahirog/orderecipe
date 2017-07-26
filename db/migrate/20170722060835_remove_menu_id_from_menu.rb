class RemoveMenuIdFromMenu < ActiveRecord::Migration
  def change
    remove_column :menus, :menu_id, :integer
  end
end
