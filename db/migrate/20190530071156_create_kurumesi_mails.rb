class CreateKurumesiMails < ActiveRecord::Migration[4.2][5.2]
  def change
    create_table :kurumesi_mails do |t|
      t.integer :masu_order_id
      t.string :subject
      t.text :body
      t.integer :summary
      t.datetime :recieved_datetime
      t.boolean :masu_order_reflect_flag,null:false
      t.timestamps
    end
  end
end
