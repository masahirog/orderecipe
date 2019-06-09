class AddColumnToMaterial < ActiveRecord::Migration[4.2][5.0]
  def change
    add_column :materials, :order_unit_quantity, :float
  end
end

