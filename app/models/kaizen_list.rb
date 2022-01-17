class KaizenList < ApplicationRecord
  mount_uploader :before_image, ImageUploader
  mount_uploader :after_image, ImageUploader
  belongs_to :product
  enum status: {yet:0,do:1,done:2,skip:3,cancel:4}
end
