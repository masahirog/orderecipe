class CreateProductPops < ActiveRecord::Migration[5.2]
  def change
    create_table :product_pops do |t|
      t.integer :product_id,null:false
      t.string :image
      t.timestamps
    end
  end
end
