class CreateBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :brands do |t|
      t.string :name,null:false,unique:true
      t.string :store_path
      t.timestamps
      t.integer :group_id,null:false
    end
  end
end
