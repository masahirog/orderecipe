class CreateItemExpirationDates < ActiveRecord::Migration[6.0]
  def change
    create_table :item_expiration_dates do |t|
      t.date :expiration_date,null:false
      t.integer :item_id,null:false
      t.integer :number
      t.date :notice_date
      t.boolean :done_flag,null:false,default:false
      t.text :memo
      t.timestamps
    end
  end
end
