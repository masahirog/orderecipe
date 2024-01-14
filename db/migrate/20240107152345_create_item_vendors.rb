class CreateItemVendors < ActiveRecord::Migration[6.0]
  def change
    create_table :item_vendors do |t|
      t.string :store_name
      t.string :producer_name
      t.string :area
      t.integer :payment
      t.string :bank_name
      t.string :bank_store_name
      t.string :bank_category
      t.string :account_number
      t.string :account_title
      t.string :zip_code
      t.string :address
      t.string :tel
      t.string :charge_person
      t.timestamps
      t.boolean :unused_flag,null:false,default:false
    end
  end
end
