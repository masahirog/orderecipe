class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.timestamps
      t.string :task_slack_url
    end
  end
end
