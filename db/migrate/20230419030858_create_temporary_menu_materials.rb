class CreateTemporaryMenuMaterials < ActiveRecord::Migration[6.0]
  def change
    create_table :temporary_menu_materials do |t|
			t.integer :menu_material_id,null:false
			t.integer :material_id,null:false
			t.date :date
      t.timestamps
      t.integer :origin_material_id
      t.index [:date, :menu_material_id], unique: true
    end
  end
end
