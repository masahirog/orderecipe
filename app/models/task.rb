class Task < ApplicationRecord
  has_many :task_comments
  enum status: {todo:0,doing:1,checking:2,done:3}
  has_many :task_staffs, dependent: :destroy
  accepts_nested_attributes_for :task_staffs, allow_destroy: true

end
