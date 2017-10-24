class AddDetailsToMaterials < ActiveRecord::Migration[5.0]
  def change
    add_column :materials, :order_unit, :string
  end
end
