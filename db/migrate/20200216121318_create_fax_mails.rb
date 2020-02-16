class CreateFaxMails < ActiveRecord::Migration[5.2]
  def change
    create_table :fax_mails do |t|
      t.integer :order_id
      t.integer :vendor_id
      t.integer :status,default:0
      t.string :subject
      t.datetime :recieved

      t.timestamps
    end
  end
end
