class StoreDailyMenuDetail < ApplicationRecord
  belongs_to :store_daily_menu,optional:true
  belongs_to :product
  belongs_to :serving_plate
  has_many :store_daily_menu_detail_histories
  validates :store_daily_menu_id, :uniqueness => {:scope => :product_id}

end