class ReminderTemplate < ApplicationRecord
  enum repeat_type: {everyday:1,mon:2,tue:3,wed:4,thu:5,fri:6,sat:7,sun:8,beg_of_month:9,end_of_month:10,every_sales_day:11}
  has_many :reminder_template_stores, dependent: :destroy
  accepts_nested_attributes_for :reminder_template_stores, reject_if: :store_id_present, allow_destroy: true
  has_many :stores, through: :reminder_template_stores

  def store_id_present(attributes)
    exists = attributes[:id].present?
    empty = attributes[:store_id].blank?
    attributes.merge!(_destroy: 1) if exists && empty
    !exists && empty
  end
end
