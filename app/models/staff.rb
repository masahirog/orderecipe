class Staff < ApplicationRecord
  belongs_to :store
  has_many :shifts
  has_many :default_shifts
  has_many :task_staffs
  enum employment_status: {part_time:0,employee:1}
  enum status: {working:0,retirement:1}

end
