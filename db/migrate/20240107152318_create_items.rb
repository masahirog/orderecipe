class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.integer :variety_id
      t.text :memo
      t.boolean :reduced_tax_flag,null:false,default:true
      t.integer :sell_price
      t.integer :tax_including_sell_price
      t.integer :purchase_price
      t.integer :tax_including_purchase_price
      t.integer :unit
      t.integer :item_vendor_id,null:false
      t.timestamps
      t.string :smaregi_code
      t.string :sales_life
    end
  end
end
