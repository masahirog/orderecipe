class DailyMenuDetail < ApplicationRecord
  belongs_to :daily_menu
  belongs_to :product
end
