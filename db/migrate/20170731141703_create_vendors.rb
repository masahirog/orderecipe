class CreateVendors < ActiveRecord::Migration[4.2][5.0]
  def change
    create_table :vendors do |t|
      t.string :company_name, unique: true
      t.string :company_phone
      t.string :company_fax
      t.string :company_mail
      t.string :zip
      t.text :address
      t.string :staff_name
      t.string :staff_phone
      t.string :staff_mail
      t.string :management_id
      t.string :efax_address
      t.text :memo
      t.string :delivery_date
      t.integer :status,default:0,null:false
      t.timestamps
      t.boolean :fax_staff_name_display_flag,default:false,null:false
    end
  end
end
