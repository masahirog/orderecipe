class AddFoodLabelNameToMenu < ActiveRecord::Migration[5.0]
  def change
    add_column :menus, :food_label_name, :string
  end
end
