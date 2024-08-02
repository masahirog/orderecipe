class CreateMenus < ActiveRecord::Migration[4.2]
  def change
    create_table :menus do |t|
      t.string :name
      t.string :roma_name
      t.text :cook_the_day_before
      t.integer :category
      t.text :serving_memo
      t.float :cost_price
      t.string :used_additives, null: false, default: ''
      t.text :cook_on_the_day
      t.string :image
      t.integer :base_menu_id
      t.timestamps null: false
      t.string :short_name
      t.integer :group_id, :null => false
      t.float :calorie,null:false,default:0
      t.float :protein,null:false,default:0
      t.float :lipid,null:false,default:0
      t.float :carbohydrate,null:false,default:0
      t.float :dietary_fiber,null:false,default:0
      t.float :salt,null:false,default:0
      t.string :food_label_name
      t.text :food_label_contents
      t.boolean :seibun_keisan_done_flag,null:false,default:false
    end
  end
end
