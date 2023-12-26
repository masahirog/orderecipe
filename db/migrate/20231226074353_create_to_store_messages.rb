class CreateToStoreMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :to_store_messages do |t|
      t.date :date
      t.text :content
      t.timestamps
    end
  end
end
