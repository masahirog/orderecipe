class CreateKurumesiMails < ActiveRecord::Migration[5.2]
  def change
    create_table :kurumesi_mails do |t|
      t.text :message

      t.timestamps
    end
  end
end
