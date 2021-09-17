class TaskTemplate < ApplicationRecord
  enum repeat_type: {毎日:1,毎週月曜:2,毎週火曜:3,毎週水曜:4,毎週木曜:5,毎週金曜:6,毎週土曜:7,毎週日曜:8,毎月初:9,毎月末:10}
  has_many :task_template_stores, dependent: :destroy
  accepts_nested_attributes_for :task_template_stores, allow_destroy: true
  has_many :stores, through: :task_template_stores
end
