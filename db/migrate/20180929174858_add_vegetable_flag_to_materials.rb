class AddVegetableFlagToMaterials < ActiveRecord::Migration[5.0]
  def change
    add_column :materials, :vegetable_flag, :integer, null: false, default: 0
  end
end
