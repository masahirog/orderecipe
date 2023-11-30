class CreateProductBbs < ActiveRecord::Migration[6.0]
  def change
    create_table :product_bbs do |t|
      t.integer :product_id,null:false
      t.string :image
      t.text :memo
      t.integer :staff_id,null:false
      t.timestamps
    end
  end
end
