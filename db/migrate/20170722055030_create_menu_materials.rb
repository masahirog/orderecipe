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
      t.integer :food_ingredient_id
      t.float :calorie
      t.float :protein
      t.float :lipid
      t.float :carbohydrate
      t.float :dietary_fiber
      t.float :potassium
      t.float :calcium
      t.float :vitamin_b1
      t.float :vitamin_b2
      t.float :vitamin_c
      t.float :salt
      t.float :magnesium
      t.float :iron
      t.float :zinc
      t.float :copper
      t.float :folic_acid
      t.float :vitamin_d
      t.integer :base_menu_material_id
      t.boolean :source_flag,default:false,null:false
      t.integer :source_group,default:0,null:false
      t.boolean :first_flag,default:false,null:false
      t.boolean :machine_flag,default:false,null:false
      t.timestamps
    end
  end
end
