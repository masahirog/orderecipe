class KurumesiOrderDetail < ApplicationRecord
  belongs_to :kurumesi_order
  belongs_to :product
  validates :kurumesi_order_id, :uniqueness => {:scope => :product_id}
end
