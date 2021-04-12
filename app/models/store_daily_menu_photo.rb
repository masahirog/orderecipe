class StoreDailyMenuPhoto < ApplicationRecord
  belongs_to :store_daily_menu
  mount_uploader :image, DailyMenuPhotoUploader

end
