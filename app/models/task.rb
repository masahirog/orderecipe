class Task < ApplicationRecord
  belongs_to :store
  enum status: {yet:0,done:1,cancel:2}
  validates :action_date, presence: true
  validates :content, presence: true
  validates :drafter, presence: true


  def self.chatwork_notice(task,store_ids)
    NotificationMailer.task_create_send_mail(task,store_ids).deliver
  end

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
  def self.yet_task_move_nextday
    today = Date.today
    yesterday = today - 1
    update_tasks_arr = []
    Task.where(action_date:yesterday,status:0).each do |task|
      task.action_date = today
      task.content = task.content + "｜#{yesterday.strftime("%-m/%-d")}繰越"
      update_tasks_arr << task
    end
    Task.import update_tasks_arr, on_duplicate_key_update: [:action_date,:content]
  end
end
