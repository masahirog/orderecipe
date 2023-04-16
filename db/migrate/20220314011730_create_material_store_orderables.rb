class CreateMaterialStoreOrderables < ActiveRecord::Migration[5.2]
  def change
    create_table :material_store_orderables do |t|
      t.integer :material_id,null:false
      t.integer :store_id,null:false
      t.boolean :orderable_flag,null:false,default:false
      t.timestamps
      t.index [:material_id,:store_id], unique: true
      t.string :order_criterion
      t.boolean :mon,null:false,default:false
      t.boolean :tue,null:false,default:false
      t.boolean :wed,null:false,default:false
      t.boolean :thu,null:false,default:false
      t.boolean :fri,null:false,default:false
      t.boolean :sat,null:false,default:false
      t.boolean :sun,null:false,default:false
      t.date :last_inventory_date
    end
  end
end
