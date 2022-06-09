class ReminderTemplateStore < ApplicationRecord
  belongs_to :reminder_template
  belongs_to :store
end
