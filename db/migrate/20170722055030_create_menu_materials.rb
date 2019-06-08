class CreateMenuMaterials < ActiveRecord::Migration[4.2]
  def change
    create_table :menu_materials do |t|
      t.integer :menu_id
      t.integer :material_id
      t.float :amount_used
      t.timestamps
    end
  end
end
