class AddColumnsToMenus < ActiveRecord::Migration[5.0]
  def change
    add_column :menus, :taste_description, :text
  end
end
