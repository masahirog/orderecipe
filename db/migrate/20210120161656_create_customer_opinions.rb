class CreateCustomerOpinions < ActiveRecord::Migration[5.2]
  def change
    create_table :customer_opinions do |t|
      t.date :date
      t.text :content

      t.timestamps
    end
  end
end
