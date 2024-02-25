class CreateItemTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :item_types do |t|
      t.string :name,null:false
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
