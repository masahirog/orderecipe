class Task < ApplicationRecord
  belongs_to :store
  enum status: {未完了:0,完了:1}
  validates :action_date, presence: true
  validates :content, presence: true
  validates :drafter, presence: true


  def self.reminder_bulk_create
    new_tasks_arr = []
    today = Date.today
    wday = today.in_time_zone('Tokyo').wday
    wday_hash = {'mon'=>1,'tue'=>2,'wed'=>3,'thu'=>4,'fri'=>5,'sat'=>6,'sun'=>0}
    TaskTemplate.where(status:0).each do |task_template|
      if task_template.repeat_type == 'everyday'
        new_task_create(task_template,new_tasks_arr,today)
      elsif  task_template.repeat_type == 'beg_of_month'
        new_task_create(task_template,new_tasks_arr,today) if today == today.beginning_of_month
      elsif  task_template.repeat_type == 'end_of_month'
        new_task_create(task_template,new_tasks_arr,today) if today == today.end_of_month
      else
        if wday_hash[task_template.repeat_type] == wday
          new_task_create(task_template,new_tasks_arr,today)
        end
      end
    end
    Task.import new_tasks_arr
  end
  def self.new_task_create(task_template,new_tasks_arr,today)
    task_template.stores.each do |store|
      new_task = Task.new(store_id:store.id,task_template_id:task_template.id,action_date:today,action_time:task_template.action_time,
      content:task_template.content,memo:task_template.memo,status:0,drafter:task_template.drafter)
      new_tasks_arr << new_task
    end
  end
end
