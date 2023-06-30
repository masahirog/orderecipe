class CreateStores < ActiveRecord::Migration[5.2]
  def change
    create_table :stores do |t|
      t.string :name, unique: true,null:false
      t.string :phone
      t.string :fax
      t.string :email
      t.string :zip
      t.text :address
      t.string :staff_name
      t.string :staff_phone
      t.string :staff_email
      t.text :memo
      t.boolean :jfd ,default:false,null:false
      t.integer :user_id
      t.integer :smaregi_store_id
      t.timestamps
      t.integer :lunch_default_shift
      t.integer :dinner_default_shift
      t.string :orikane_store_code
      t.string :short_name
      t.string :np_store_code
      t.integer :group_id
      t.string :task_slack_url
      t.integer :store_type,default:0,null:false
    end
  end
end
