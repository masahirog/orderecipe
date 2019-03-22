class DailyMenu < ApplicationRecord
  has_many :daily_menu_details, ->{order("product_id") }, dependent: :destroy
  accepts_nested_attributes_for :daily_menu_details, allow_destroy: true

end
