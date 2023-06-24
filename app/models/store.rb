class Store < ApplicationRecord
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
end
