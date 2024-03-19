class ItemOrder < ApplicationRecord
	has_many :item_order_items, dependent: :destroy
	accepts_nested_attributes_for :item_order_items, allow_destroy: true, reject_if: lambda { |attributes|
	  attributes.merge!({_destroy: 1}) if attributes['order_quantity'] == "0"
	}
	belongs_to :store	
end
