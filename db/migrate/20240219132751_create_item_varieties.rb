class CreateItemVarieties < ActiveRecord::Migration[6.0]
  def change
    create_table :item_varieties do |t|
      t.references :item_type
      t.string :name,null:false
      t.string :image
      t.text :storage
      t.text :display
      t.text :feature
      t.text :cooking
      t.text :choice
      t.timestamps
    end
  end
end
