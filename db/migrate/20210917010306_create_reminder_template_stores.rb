class CreateReminderTemplateStores < ActiveRecord::Migration[5.2]
  def change
    create_table :reminder_template_stores do |t|
      t.integer :reminder_template_id,null:false
      t.integer :store_id,null:false
      t.timestamps
      # t.index [:reminder_template_id, :store_id], unique: true
    end
  end
end
