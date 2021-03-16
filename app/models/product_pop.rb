class ProductPop < ApplicationRecord
  belongs_to :product
  mount_uploader :image, ProductPopUploader
end
