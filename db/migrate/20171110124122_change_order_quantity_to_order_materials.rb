class ChangeOrderQuantityToOrderMaterials < ActiveRecord::Migration[4.2][5.0]
  #変更後の型
  def up
    change_column :order_materials, :order_quantity, :text
  end

  #変更前の型
  def down
    change_column :order_materials, :order_quantity, :integer
  end
end
