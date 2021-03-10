class StoreDailyMenuDetail < ApplicationRecord
  belongs_to :daily_menu,optional:true
  belongs_to :product
end
