class ItemOrderItem < ApplicationRecord
	belongs_to :item
	belongs_to :item_order
end
