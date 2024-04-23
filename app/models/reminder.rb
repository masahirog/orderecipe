class Reminder < ApplicationRecord
  belongs_to :store
  enum status: {yet:0,done:1,cancel:2,carry_forward:3,check:4}
  enum category: {task:0,clean:1}
  validates :action_date, presence: true
  validates :content, presence: true



  def self.reminder_bulk_create
    new_reminders_arr = []
    today = Date.today - 1
    wday = today.in_time_zone('Tokyo').wday
    wday_hash = {'mon'=>1,'tue'=>2,'wed'=>3,'thu'=>4,'fri'=>5,'sat'=>6,'sun'=>0}
    ReminderTemplate.where(status:0).each do |reminder_template|
      if reminder_template.repeat_type == 'everyday'
        new_reminder_create(reminder_template,new_reminders_arr,today)
      elsif reminder_template.repeat_type == 'beg_of_month'
        new_reminder_create(reminder_template,new_reminders_arr,today) if today == today.beginning_of_month
      elsif reminder_template.repeat_type == 'end_of_month'
        new_reminder_create(reminder_template,new_reminders_arr,today) if today == today.end_of_month
      elsif reminder_template.repeat_type == 'everyweek'
        new_reminder_create(reminder_template,new_reminders_arr,today) if today == today.beginning_of_week
      elsif reminder_template.repeat_type == 'everymonth'
        new_reminder_create(reminder_template,new_reminders_arr,today) if today == today.beginning_of_month

      else
        if wday_hash[reminder_template.repeat_type] == wday
          new_reminder_create(reminder_template,new_reminders_arr,today)
        end
      end
    end
    Reminder.import new_reminders_arr
  end
  def self.new_reminder_create(reminder_template,new_reminders_arr,today)
    reminder_template.stores.each do |store|
      new_reminder = Reminder.new(store_id:store.id,reminder_template_id:reminder_template.id,action_date:today,action_time:reminder_template.action_time,
      content:reminder_template.content,memo:reminder_template.memo,status:0,drafter:reminder_template.drafter,category:reminder_template.category)
      new_reminders_arr << new_reminder
    end
  end
  def self.yet_reminder_move_nextday
    today = Date.today
    yesterday = today - 1
    update_reminders_arr = []
    Reminder.where(action_date:yesterday,status:3).each do |reminder|
      reminder.action_date = today
      reminder.content = reminder.content + "｜#{yesterday.strftime("%-m/%-d")}繰越"
      update_reminders_arr << reminder
    end
    Reminder.import update_reminders_arr, on_duplicate_key_update: [:action_date,:content]
  end
end
