class CreateToStoreMessageStores < ActiveRecord::Migration[6.0]
  def change
    create_table :to_store_message_stores do |t|
      t.integer :to_store_message_id,null:false
      t.integer :store_id
      t.boolean :subject_flag,default:false
      t.timestamps
    end
  end
end
