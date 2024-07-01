class WeeklyReport < ApplicationRecord
	belongs_to :store
	belongs_to :staff
	has_many :weekly_report_thanks,dependent: :destroy
	accepts_nested_attributes_for :weekly_report_thanks, allow_destroy: true
end
