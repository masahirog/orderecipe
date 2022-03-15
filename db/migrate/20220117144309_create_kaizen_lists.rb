class CreateKaizenLists < ActiveRecord::Migration[5.2]
  def change
    create_table :kaizen_lists do |t|
      t.integer :product_id
      t.string :author
      t.string :kaizen_staff
      t.text :kaizen_point
      t.integer :priority,default:0,null:false
      t.integer :status,default:0,null:false
      t.text :kaizen_result
      t.boolean :or_change_flag,default:0,null:false
      t.boolean :share_flag,default:0,null:false
      t.timestamps
      t.string :before_image
      t.string :after_image
      t.integer :store_id,null:false
    end
  end
end
