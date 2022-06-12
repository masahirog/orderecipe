class Task < ApplicationRecord
  has_many :task_comments,dependent: :destroy
  has_many :task_staffs, dependent: :destroy
  accepts_nested_attributes_for :task_staffs, allow_destroy: true
  has_many :task_images, dependent: :destroy
  accepts_nested_attributes_for :task_images, allow_destroy: true

  enum status: {todo:0,doing:1,check:2,done:3}
  enum category: {task:0,kaizen:1,project:2}
  include RankedModel
  ranks :row_order, :with_same => :status
end
