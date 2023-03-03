class TaskStore < ApplicationRecord
	belongs_to :task
	belongs_to :store
end
