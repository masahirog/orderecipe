class CreateBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :brands do |t|
      t.string :name,null:false,unique:true
      t.timestamps
      t.integer :group_id,null:false
      t.boolean :unused_flag,null:false,default:false
    end
  end
end
