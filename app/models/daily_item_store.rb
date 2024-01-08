class DailyItemStore < ApplicationRecord
	belongs_to :store
	belongs_to :daily_item
end
