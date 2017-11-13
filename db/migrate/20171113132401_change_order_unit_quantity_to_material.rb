class ChangeOrderUnitQuantityToMaterial < ActiveRecord::Migration[5.0]
  #変更後の型
  def up
    change_column :materials, :order_unit_quantity, :text
  end

  #変更前の型
  def down
    change_column :materials, :order_unit_quantity, :float
  end
end
