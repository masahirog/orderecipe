class TaskTemplate < ApplicationRecord
  enum repeat_type: {everyday:1,mon:2,tue:3,wed:4,thu:5,fri:6,sat:7,sun:8,beg_of_month:9,end_of_month:10}
  has_many :task_template_stores, dependent: :destroy
  accepts_nested_attributes_for :task_template_stores, allow_destroy: true
  has_many :stores, through: :task_template_stores
end
