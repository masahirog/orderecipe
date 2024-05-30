class PreOrder < ApplicationRecord
	has_many :pre_order_products, dependent: :destroy
  	accepts_nested_attributes_for :pre_order_products, allow_destroy: true, reject_if: lambda { |attributes|
		attributes.merge!({_destroy: 1}) if attributes['order_num'] == "0"
	}
	belongs_to :store
end
