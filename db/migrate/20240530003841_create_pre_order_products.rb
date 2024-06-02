class CreatePreOrderProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :pre_order_products do |t|
      t.references :pre_order,null:false
      t.references :product,null:false
      t.integer :order_num,null:false,default:0
      t.integer :tax_including_sell_price,null:false,default:0
      t.integer :subtotal,null:false,default:0
      t.integer :welfare_price,null:false,default:0
      t.integer :employee_discount,null:false,default:0
      t.timestamps
    end
  end
end
