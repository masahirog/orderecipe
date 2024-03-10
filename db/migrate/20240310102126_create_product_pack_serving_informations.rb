class CreateProductPackServingInformations < ActiveRecord::Migration[6.0]
  def change
    create_table :product_pack_serving_informations do |t|
      t.integer :product_id,null:false
      t.integer :row_order,null:false,default:0
      t.string :image
      t.text :content
      t.timestamps
    end
  end
end
