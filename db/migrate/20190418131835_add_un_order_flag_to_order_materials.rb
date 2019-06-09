class AddUnOrderFlagToOrderMaterials < ActiveRecord::Migration[4.2][5.2]
  def change
    add_column :order_materials, :un_order_flag, :boolean,default:false,null:false
  end
end

