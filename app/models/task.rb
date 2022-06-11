class Task < ApplicationRecord
  has_many :task_comments,dependent: :destroy
  has_many :task_staffs, dependent: :destroy
  accepts_nested_attributes_for :task_staffs, allow_destroy: true
  enum status: {todo:0,doing:1,checking:2,done:3}
  include RankedModel
  ranks :row_order, :with_same => :status
end
