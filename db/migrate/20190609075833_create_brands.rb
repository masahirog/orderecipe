class CreateBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :brands do |t|
      t.string :name,null:false,unique:true
      t.boolean :kurumesi_flag,null:false,default:false
      t.string :store_path
      t.timestamps
      t.integer :group_id,null:false
    end
  end
end
