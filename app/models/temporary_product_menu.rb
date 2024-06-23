class TemporaryProductMenu < ApplicationRecord
	belongs_to :product_menu
	belongs_to :menu
	belongs_to :daily_menu_detail
end
