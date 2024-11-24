class Staff < ApplicationRecord
	belongs_to :group
    has_many :staff_stores,dependent: :destroy
    has_many :stores, through: :staff_stores
    accepts_nested_attributes_for :staff_stores, allow_destroy: true
    has_many :shifts
    has_many :default_shifts
    has_many :task_staffs
    has_many :tastings
    has_many :sales_reports
    has_many :working_hours
    has_many :sales_report_staffs
    has_many :weekly_reports
    has_many :sales_report_thanks
    enum employment_status: {part_time:0,employee:1}
    enum status: {working:0,retirement:1}

end
