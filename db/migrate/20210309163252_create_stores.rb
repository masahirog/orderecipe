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

      t.timestamps
    end
  end
end
