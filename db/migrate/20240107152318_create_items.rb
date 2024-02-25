class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :name,null:false
      t.references :item_variety
      t.text :memo
      t.boolean :reduced_tax_flag,null:false,default:true
      t.integer :sell_price
      t.integer :tax_including_sell_price
      t.integer :purchase_price
      t.integer :tax_including_purchase_price
      t.integer :unit
      t.references :item_vendor
      t.timestamps
      t.string :smaregi_code
      t.string :sales_life
    end
  end
end
