class CreateWikis < ActiveRecord::Migration[5.2]
  def change
    create_table :wikis do |t|
      t.string :name
      t.text :summary
      t.integer :row_order
      t.timestamps
    end
  end
end
