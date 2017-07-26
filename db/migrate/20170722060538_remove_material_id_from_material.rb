class RemoveMaterialIdFromMaterial < ActiveRecord::Migration
  def change
    remove_column :materials, :material_id, :integer
  end
end
