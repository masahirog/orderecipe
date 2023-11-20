class Manual < ApplicationRecord
	mount_uploader :video, VideoUploader
	has_ancestry
end
