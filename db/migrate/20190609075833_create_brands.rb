class CreateBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :brands do |t|
      t.string :name,null:false,unique:true
      t.integer :store_id,null:false
      t.timestamps
    end
  end
end
