class CreateContainers < ActiveRecord::Migration[5.2]
  def change
    create_table :containers do |t|
      t.string :name
      t.timestamps
      t.integer :group_id,null:false
      t.boolean :inversion_label_flag,default:true,null:false
    end
  end
end
