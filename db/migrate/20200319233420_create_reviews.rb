class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.integer :brand_id
      t.date :delivery_date
      t.string :delivery_area
      t.string :title
      t.text :post
      t.string :use_scene
      t.string :age
      t.string :score
      t.boolean :line_sended,default:false

      t.timestamps
    end
  end
end
