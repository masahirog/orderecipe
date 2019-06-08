class AddDetailsToMenus < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :menus, :image, :string
  end
end
