class CreateRefundSupports < ActiveRecord::Migration[5.2]
  def change
    create_table :refund_supports do |t|
      t.datetime :occurred_at,null:false
      t.integer :store_id,null:false
      t.integer :status,default:0,null:false
      t.string :staff_name
      t.text :content
      t.date :visit_date
      t.timestamps
    end
  end
end
