class CreateProductParts < ActiveRecord::Migration[5.2]
  def change
    create_table :product_parts do |t|
      t.integer :product_id,null:false
      t.string :name,null:false,default:''
      t.integer :amount,null:false,default:0
      t.string :unit,null:false

      t.timestamps
    end
  end
end
