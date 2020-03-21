class CreateBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :brands do |t|
      t.string :name,null:false,unique:true
      t.integer :store_id,null:false
      t.boolean :kurumesi_flag,null:false
      t.string :store_path
      t.timestamps
    end
  end
end
