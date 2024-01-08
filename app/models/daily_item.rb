class DailyItem < ApplicationRecord
	has_many :daily_item_stores, dependent: :destroy
	has_many :stores,through: :daily_item_stores
	accepts_nested_attributes_for :daily_item_stores, allow_destroy: true
	belongs_to :item
end
