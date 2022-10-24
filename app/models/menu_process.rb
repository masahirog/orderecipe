class MenuProcess < ApplicationRecord
  mount_uploader :image, ImageUploader
  belongs_to :menu
end
