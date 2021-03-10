class StoreDailyMenu < ApplicationRecord
  belongs_to :daily_menu
  belongs_to :store
  has_many :store_daily_menu_details, ->{order("row_order") }, dependent: :destroy
  has_many :products, through: :store_daily_menu_details
  accepts_nested_attributes_for :store_daily_menu_details, allow_destroy: true
  enum weather: {sunny:1, cloud:2,rain:3,strong_rain:4,taihoon:5,snow:6}
  validates :daily_menu_id, :uniqueness => {:scope => :store_id}
end
