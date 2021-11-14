class CreateCustomerOpinions < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_opinions do |t|
      t.date :date
      t.integer :evaluation
      t.integer :taste
      t.integer :price
      t.integer :service
      t.bigint :receipt_number
      t.text :content
      t.string :mail
      t.integer :store_id
      t.timestamps
    end
  end
end
