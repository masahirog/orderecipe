class DailyItem < ApplicationRecord
	has_many :daily_item_stores, dependent: :destroy
	has_many :stores,through: :daily_item_stores
	accepts_nested_attributes_for :daily_item_stores, allow_destroy: true
	belongs_to :item
	enum unit: {袋:1,cs:2,本:3,kg:4,個:5,pc:6}

end
