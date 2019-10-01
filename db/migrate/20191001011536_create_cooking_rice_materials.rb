class CreateCookingRiceMaterials < ActiveRecord::Migration[5.2]
  def change
    create_table :cooking_rice_materials do |t|
      t.integer :cooking_rice_id,null:false
      t.integer :material_id,null:false
      t.float :used_amount,null:false,default:0

      t.timestamps
    end
  end
end
