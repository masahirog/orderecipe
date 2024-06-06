class CreateProductParts < ActiveRecord::Migration[5.2]
  def change
    create_table :product_parts do |t|
      t.integer :product_id,null:false
      t.string :name,null:false,default:''
      t.float :amount,null:false,default:0
      t.string :unit,null:false
      t.string :memo
      t.integer :container,null:false,default:0
      t.boolean :sticker_print_flag, null: false, default: true
      t.timestamps
      t.references :common_product_part
      t.integer :loading_container,null:false,default:0
      t.integer :loading_position,null:false,default:0
    end
  end
end
