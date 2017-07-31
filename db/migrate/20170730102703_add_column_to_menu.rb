class AddColumnToMenu < ActiveRecord::Migration[5.0]
  def change
    add_column :menus, :cost_price, :float
  end
end
