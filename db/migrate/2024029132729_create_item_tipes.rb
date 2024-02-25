class CreateItemTipes < ActiveRecord::Migration[6.0]
  def change
    create_table :item_tipes do |t|
      t.string :name,null:false
      t.integer :genre
      t.integer :category
      t.text :storage
      t.text :display
      t.text :feature
      t.text :cooking
      t.text :choice
      t.timestamps
    end
  end
end
