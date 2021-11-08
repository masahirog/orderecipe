class CreateSmaregiMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :smaregi_members do |t|
      t.integer :kaiin_id,null:false
      t.string :kaiin_code,null:false
      t.string :sei_kana,null:false
      t.string :mei_kana,null:false
      t.string :mobile,null:false
      t.integer :sex,default:0,null:false
      t.date :birthday
      t.integer :point
      t.date :point_limit
      t.datetime :last_visit_store
      t.date :nyukaibi
      t.date :taikaibi
      t.text :memo
      t.integer :kaiin_zyotai,default:0,null:false
      t.integer :main_use_store,null:false
      t.timestamps
    end
  end
end
