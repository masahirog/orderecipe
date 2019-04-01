class DailyMenu < ApplicationRecord
  has_many :daily_menu_details, ->{order("row_order") }, dependent: :destroy
  accepts_nested_attributes_for :daily_menu_details, allow_destroy: true

end
