class MasuOrderDetail < ApplicationRecord
  belongs_to :masu_order
  belongs_to :product
end
