class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :name,null:false
      t.references :item_variety
      t.text :memo
      t.boolean :reduced_tax_flag,null:false,default:true
      t.integer :sell_price,null:false,default:0
      t.integer :tax_including_sell_price,null:false,default:0
      t.integer :purchase_price,null:false
      t.integer :tax_including_purchase_price,null:false
      t.integer :unit,null:false
      t.references :item_vendor
      t.timestamps
      t.string :smaregi_code
      t.string :sales_life
      t.integer :order_unit,null:false
      t.integer :order_unit_amount,null:false
    end
  end
end
