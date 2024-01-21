class DailyItem < ApplicationRecord
	has_many :daily_item_stores, dependent: :destroy
	has_many :stores,through: :daily_item_stores
	accepts_nested_attributes_for :daily_item_stores, allow_destroy: true
	belongs_to :item
	enum purpose:{物販:0,惣菜:1}
	enum unit: {袋:1,cs:2,本:3,kg:4,個:5,pc:6,口:7}
	before_save :calculate

	def calculate
		zeinuki_uriage = 0
		zeikomi_uriage = 0
		self.daily_item_stores.each do |dis|
			subordinate_amount = dis.subordinate_amount
			sell_price = dis.sell_price
			if dis.daily_item.item.reduced_tax_flag == true
				tax_rate = 1.08
			else
				tax_rate = 1.1
			end
			tax_including_sell_price = (sell_price * tax_rate).floor
			dis.tax_including_sell_price = tax_including_sell_price
			zeinuki_uriage += (sell_price * subordinate_amount)
			zeikomi_uriage += (tax_including_sell_price * subordinate_amount)
		end
		self.estimated_sales = zeinuki_uriage
		self.tax_including_estimated_sales = zeikomi_uriage
	end

end
