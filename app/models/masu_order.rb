class MasuOrder < ApplicationRecord
  has_many :masu_order_details, dependent: :destroy
  accepts_nested_attributes_for :masu_order_details, allow_destroy: true
end
