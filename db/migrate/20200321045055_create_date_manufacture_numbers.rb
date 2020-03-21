class CreateDateManufactureNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :date_manufacture_numbers do |t|
      t.date :date
      t.integer :num
      t.boolean :notified_flag,default:false

      t.timestamps
    end
  end
end
