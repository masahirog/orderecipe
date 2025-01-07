class Store < ApplicationRecord
  has_many :to_store_messages,through: :to_store_messages_stores
  belongs_to :user
  belongs_to :group
  has_many :store_daily_menus
  has_many :analyses
  has_many :reminder_template_stores
  has_many :reminders
  has_many :product_sales_potentials
  has_many :staff_stores
  has_many :staffs, through: :staff_stores
  has_many :shifts
  has_many :default_shifts
  has_many :orders
  has_many :material_store_orderables
  has_many :store_shift_frames, dependent: :destroy
  has_many :shift_frames, through: :store_shift_frames
  has_many :refund_supports
  accepts_nested_attributes_for :store_shift_frames, allow_destroy: true
  has_many :monthly_stocks
  has_many :task_stores
  has_many :fix_shift_pattern_stores
  has_many :fix_shift_patterns, through: :fix_shift_pattern_stores
  has_many :daily_item_stores
  has_many :item_store_stocks
  has_many :working_hours
  has_many :item_orders


  enum store_type: {sales:0,kitchen:1,head_office:2}
end
