class AddFixedFlagToOrder < ActiveRecord::Migration[4.2][5.2]
  def change
    add_column :orders, :fixed_flag, :boolean,null:false,default:false
  end
end
