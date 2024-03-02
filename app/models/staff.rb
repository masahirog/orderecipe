class Staff < ApplicationRecord
	belongs_to :group
  has_many :staff_stores,dependent: :destroy
  accepts_nested_attributes_for :staff_stores,allow_destroy:true,:reject_if => :reject_store_blank
  has_many :stores, through: :staff_stores
  has_many :shifts
  has_many :default_shifts
  has_many :task_staffs
  has_many :tastings
  has_many :sales_reports
  has_many :working_hours
  enum employment_status: {part_time:0,employee:1}
  enum status: {working:0,retirement:1}

  def reject_store_blank(attributes)
    attributes.merge!(_destroy:"1") if attributes[:affiliation_flag] == "0"
  end

end
