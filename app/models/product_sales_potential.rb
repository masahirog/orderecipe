class ProductSalesPotential < ApplicationRecord
  belongs_to :store_id
  belongs_to :product_id
end
