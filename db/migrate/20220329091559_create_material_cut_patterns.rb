class CreateMaterialCutPatterns < ActiveRecord::Migration[5.2]
  def change
    create_table :material_cut_patterns do |t|
      t.integer :material_id,null:false
      t.string :name
      t.integer :machine
      t.timestamps
      t.string :roma_name
    end
  end
end
