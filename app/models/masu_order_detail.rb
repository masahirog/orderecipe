class MasuOrderDetail < ApplicationRecord
  belongs_to :masu_order
  belongs_to :product
  validates :masu_order_id, :uniqueness => {:scope => :product_id}
end
