class Tasting < ApplicationRecord
	belongs_to :staff
	belongs_to :product
	mount_uploader :image, ImageUploader
end
