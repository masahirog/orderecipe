class CreateKurumesiAdminData < ActiveRecord::Migration[5.2]
  def change
    create_table :kurumesi_admin_data do |t|
      t.string :store_name
      t.date :delivery_date
      t.time :pick_time
      t.string :delivery_time
      t.string :delivery_address
      t.text :products
      t.string :order_price
      t.string :total_price
      t.string :delivery_company
      t.string :delivery_name
      t.string :payment
      t.datetime :order_date
      t.string :status
      t.integer :order_id
      t.integer :member_id
      t.string :orderer_name
      t.string :orderer_company
      t.string :orderer_mail
      t.string :orderer_tell
      t.string :ordered_site
      t.string :ordered_type

      t.timestamps
    end
  end
end
