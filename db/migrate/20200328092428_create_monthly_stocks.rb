class CreateMonthlyStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :monthly_stocks do |t|
      t.date :date, unique: true
      t.integer :item_number
      t.integer :total_amount
      t.integer :foods_amount
      t.integer :equipments_amount
      t.integer :expendables_amount

      t.timestamps
    end
  end
end
