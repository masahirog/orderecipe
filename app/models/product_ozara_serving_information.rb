class ProductOzaraServingInformation < ApplicationRecord
  belongs_to :product
  mount_uploader :image, ProductOzaraServingInformationUploader
end
