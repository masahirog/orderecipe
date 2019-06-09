class CreateStorageLocations < ActiveRecord::Migration[4.2][5.2]
  def change
    create_table :storage_locations do |t|
      t.string :name,null:false, unique: true

      t.timestamps
    end
  end
end
