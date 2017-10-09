class CreateMenuMaterials < ActiveRecord::Migration
  def change
    create_table :menu_materials do |t|
      t.integer :menu_id
      t.integer :material_id
      t.float :amount_used
      t.timestamps
    end
  end
end
