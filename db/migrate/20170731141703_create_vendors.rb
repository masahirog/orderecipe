class CreateVendors < ActiveRecord::Migration[5.0]
  def change
    create_table :vendors do |t|
      t.string :company_name
      t.string :company_phone
      t.string :company_fax
      t.string :company_mail
      t.string :zip
      t.text :address
      t.string :staff_name
      t.string :staff_phone
      t.string :staff_mail
      t.text :memo
      t.timestamps
    end
  end
end
