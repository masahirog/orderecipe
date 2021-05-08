class CreateWikiItems < ActiveRecord::Migration[5.2]
  def change
    create_table :wiki_items do |t|
      t.integer :wiki_id
      t.integer :row_order
      t.string :title
      t.text :content
      t.timestamps
    end
  end
end
