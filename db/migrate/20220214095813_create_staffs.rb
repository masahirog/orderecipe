class CreateStaffs < ActiveRecord::Migration[5.2]
  def change
    create_table :staffs do |t|
      t.integer :store_id
      t.string :name
      t.text :memo
      t.timestamps
    end
  end
end
