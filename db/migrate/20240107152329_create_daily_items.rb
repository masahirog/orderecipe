class CreateDailyItems < ActiveRecord::Migration[6.0]
  def change
    create_table :daily_items do |t|
      t.date :date,null:false
      t.integer :purpose,null:false
      t.integer :item_id,null:false
      t.text :memo
      t.integer :estimated_sales,default:0,null:false
      t.integer :tax_including_estimated_sales,default:0,null:false
      t.integer :purchase_price,default:0,null:false
      t.integer :tax_including_purchase_price,default:0,null:false
      t.integer :delivery_fee,default:0,null:false
      t.integer :tax_including_delivery_fee,default:0,null:false
      t.integer :subtotal_price,default:0,null:false
      t.integer :tax_including_subtotal_price,default:0,null:false
      t.integer :unit
      t.integer :delivery_amount,default:0,null:false
      t.timestamps
      t.text :sorting_memo
    end
  end
end
