class AddCategoryToMenu < ActiveRecord::Migration
  def change
    add_column :menus, :category, :string
    add_column :menus, :serving_memo, :text
  end
end
