class CreateWorkTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :work_types do |t|
      t.string :name
      t.references :group
      t.timestamps
      t.integer :row_order
      t.string :bg_color_code,default:"#4169e1",null:false
      t.boolean :rest_flag,default:false,null:false
      t.integer :category
    end
  end
end
