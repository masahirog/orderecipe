class DailyMenuPhoto < ApplicationRecord
  belongs_to :daily_menu
  mount_uploader :image, DailyMenuPhotoUploader

end
