class TaskTemplateStore < ApplicationRecord
  belongs_to :task_template
  belongs_to :store
end
