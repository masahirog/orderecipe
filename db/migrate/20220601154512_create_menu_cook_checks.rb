class CreateMenuCookChecks < ActiveRecord::Migration[5.2]
  def change
    create_table :menu_cook_checks do |t|
      t.integer :menu_id,null:false
      t.string :content,null:false,default:''
      t.timestamps
      t.integer :check_position,null:false
    end
  end
end
