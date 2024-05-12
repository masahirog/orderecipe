class CreateCommonProductParts < ActiveRecord::Migration[6.0]
  def change
    create_table :common_product_parts do |t|
      t.string :name,null:false,default:''
      t.string :unit,null:false
      t.string :memo
      t.integer :container,null:false,default:0
      t.timestamps
    end
  end
end
