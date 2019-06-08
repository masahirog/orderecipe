class AddStorageLocationToMaterials < ActiveRecord::Migration[4.2][5.2]
  def change
    add_column :materials, :storage_location_id, :integer,null:false
  end
end
