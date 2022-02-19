class CreateStaffs < ActiveRecord::Migration[5.2]
  def change
    create_table :staffs do |t|
      t.integer :store_id,null:false
      t.string :name,null:false
      t.text :memo
      t.timestamps
      t.integer :employment_status,default:0,null:false
      t.integer :row,default:0,null:false
      t.integer :status,default:0,null:false
    end
  end
end
