class Manual < ApplicationRecord
	mount_uploader :picture, VideoUploader
	belongs_to :manual_directory
end
