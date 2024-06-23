class ProductMenu < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :menu
  has_many :temporary_product_menus
end
