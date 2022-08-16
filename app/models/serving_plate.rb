class ServingPlate < ApplicationRecord
  has_many :daily_menu_details
  has_many :store_daily_menu_details
  enum color: {white:1, black:2,red:3,blue:4}
  enum shape: {circle:1,square:2}
  enum genre: {japanes:1,western:2}
  mount_uploader :image, ServingPlateImageUploader
end
