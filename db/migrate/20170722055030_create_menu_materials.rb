class CreateMenuMaterials < ActiveRecord::Migration[4.2]
  def change
    create_table :menu_materials do |t|
      t.integer :menu_id,null:false
      t.integer :material_id,null:false
      t.float :amount_used,null:false,default:0
      t.string :preparation
      t.integer :post
      t.integer :row_order,null:false,default:0
      t.float :gram_quantity
      t.float :calorie,null:false,default:0
      t.float :protein,null:false,default:0
      t.float :lipid,null:false,default:0
      t.float :carbohydrate,null:false,default:0
      t.float :dietary_fiber,null:false,default:0
      t.float :salt,null:false,default:0
      t.integer :base_menu_material_id
      t.boolean :source_flag,default:false,null:false
      t.integer :source_group
      t.boolean :first_flag,default:false,null:false
      t.boolean :machine_flag,default:false,null:false
      t.timestamps
      t.integer :material_cut_pattern_id
    end
  end
end
