class CreateCookingRices < ActiveRecord::Migration[5.2]
  def change
    create_table :cooking_rices do |t|
      t.string :name,null:false
      t.integer :base_rice,null:false
      t.integer :serving_amount,null:false
      t.float :sho_per_make_num,null:false

      t.timestamps
    end
  end
end
