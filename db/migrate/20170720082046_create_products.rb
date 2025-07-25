class CreateProducts < ActiveRecord::Migration[4.2]
  def change
    create_table :products do |t|
      t.string :name, unique: true
      t.integer :sell_price,null:false
      t.text :description
      t.text :contents
      t.float :cost_price
      t.string :image
      t.integer :status,default:1,null:false
      t.integer :brand_id
      t.integer :product_category,null:false,default:1
      t.timestamps null: false
      t.boolean :bejihan_sozai_flag, null: false, default: false
      t.string :display_image
      t.string :image_for_one_person
      t.text :serving_infomation
      t.string :food_label_name,null:false
      t.text :food_label_content
      t.boolean :carryover_able_flag, null: false, default: false
      t.integer :main_serving_plate_id
      t.integer :sub_serving_plate_id
      t.integer :container_id
      t.boolean :freezing_able_flag, null: false, default: false
      t.integer :group_id, :null => false
      t.integer :sub_category
      t.boolean :bejihan_only_flag, null: false, default: false
      t.string :smaregi_code
      t.boolean :warm_flag, null: false, default: false
      t.integer :tax_including_sell_price,null:false
      t.boolean :reduced_tax_flag,null:false,default:true
      t.boolean :half_able_flag,null:false,default:false
      t.string :sales_unit,null:false,default:'1人前'
      t.float :calorie,null:false,default:0
      t.float :protein,null:false,default:0
      t.float :lipid,null:false,default:0
      t.float :carbohydrate,null:false,default:0
      t.float :dietary_fiber,null:false,default:0
      t.float :salt,null:false,default:0
    end
  end
end
