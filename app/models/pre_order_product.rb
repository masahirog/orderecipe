class PreOrderProduct < ApplicationRecord
	belongs_to :product
	belongs_to :pre_order
end
