class Task < ApplicationRecord
  belongs_to :store
  enum status: {未完了:0,完了:1}
  validates :action_date, presence: true
  validates :content, presence: true
  validates :drafter, presence: true


  def self.reminder_bulk_create
    new_tasks_arr = []
    today = Date.today
    TaskTemplate.where(status:0).each do |task_template|
      task_template.stores.each do |store|
        new_task = Task.new(store_id:store.id,task_template_id:task_template.id,action_date:today,action_time:task_template.action_time,
        content:task_template.content,memo:task_template.memo,status:0,drafter:task_template.drafter)
        new_tasks_arr << new_task
      end
    end
    Task.import new_tasks_arr
  end
end
