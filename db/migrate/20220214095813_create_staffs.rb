class CreateStaffs < ActiveRecord::Migration[5.2]
  def change
    create_table :staffs do |t|
      t.string :name,null:false
      t.text :memo
      t.timestamps
      t.integer :employment_status,default:0,null:false
      t.integer :row,default:0,null:false
      t.integer :status,default:0,null:false
      t.integer :staff_code
      t.integer :smaregi_hanbaiin_id
      t.string :phone_number
      t.integer :group_id,null:false
      t.string :short_name,null:false
    end
  end
end
