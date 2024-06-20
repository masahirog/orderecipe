class CreateFoodIngredients < ActiveRecord::Migration[4.2][5.0]
  def change
    create_table :food_ingredients do |t|
      t.integer :food_group
      t.integer :food_number
      t.integer :index_number
      t.string :name
      t.string :complement
      t.float :calorie,null:false,default:0
      t.float :protein,null:false,default:0
      t.float :lipid,null:false,default:0
      t.float :carbohydrate,null:false,default:0
      t.float :dietary_fiber,null:false,default:0
      t.float :potassium,null:false,default:0
      t.float :calcium,null:false,default:0
      t.float :vitamin_b1,null:false,default:0
      t.float :vitamin_b2,null:false,default:0
      t.float :vitamin_c,null:false,default:0
      t.float :salt,null:false,default:0
      t.text :memo
      t.float :magnesium,null:false,default:0
      t.float :iron,null:false,default:0
      t.float :zinc,null:false,default:0
      t.float :copper,null:false,default:0
      t.float :folic_acid,null:false,default:0
      t.float :vitamin_d,null:false,default:0
      t.timestamps
    end
  end
end
