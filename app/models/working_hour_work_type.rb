class WorkingHourWorkType < ApplicationRecord
	belongs_to :working_hour
	belongs_to :work_type
end
