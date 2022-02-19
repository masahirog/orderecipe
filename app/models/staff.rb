class Staff < ApplicationRecord
  belongs_to :store
  enum employment_status: {part_time:0,employee:1}
  enum status: {working:0,retirement:1}

end
