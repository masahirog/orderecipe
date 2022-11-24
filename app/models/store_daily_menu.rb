require 'csv'
class StoreDailyMenu < ApplicationRecord
  mount_uploader :opentime_showcase_photo, ImageUploader
  mount_uploader :showcase_photo_a, ImageUploader
  mount_uploader :showcase_photo_b, ImageUploader
  mount_uploader :signboard_photo, ImageUploader
  belongs_to :daily_menu
  belongs_to :store
  has_many :store_daily_menu_details, ->{order("row_order") }, dependent: :destroy
  has_many :products, through: :store_daily_menu_details
  accepts_nested_attributes_for :store_daily_menu_details, allow_destroy: true
  has_many :store_daily_menu_photos, dependent: :destroy
  accepts_nested_attributes_for :store_daily_menu_photos
  has_one :analysis

  enum weather: {sunny:1, cloud:2,rain:3,strong_rain:4,taihoon:5,snow:6}
  validates :daily_menu_id, :uniqueness => {:scope => :store_id}

  before_save :opentime_showcase_photo_upload_check
  before_save :total_check
  after_update :input_stock
  after_destroy :input_stock


  def opentime_showcase_photo_upload_check
    if self.opentime_showcase_photo_changed?
      self.opentime_showcase_photo_uploaded = Time.now
    end
  end

  #納品量の追加
  def total_check
    self.store_daily_menu_details.each do |sdmd|
      sdmd.actual_inventory = sdmd.sozai_number + sdmd.stock_deficiency_excess - sdmd.carry_over
    end
  end

  def input_stock
    update_dmds = []
    total_manufacturing_number = 0
    daily_menu = self.daily_menu
    sdmds = StoreDailyMenuDetail.where(store_daily_menu_id:daily_menu.store_daily_menus.ids)
    product_num_hash = sdmds.group(:product_id).sum(:number)
    sozai_num_hash = sdmds.group(:product_id).sum(:sozai_number)
    bento_fukusai_num_hash = sdmds.group(:product_id).sum(:bento_fukusai_number)
    dmdps = daily_menu.daily_menu_details.pluck(:product_id).uniq
    sdmdps = sdmds.pluck(:product_id).uniq
    (sdmdps - dmdps).each do |product_id|
      DailyMenuDetail.create(daily_menu_id:daily_menu.id,product_id:product_id,manufacturing_number:product_num_hash[product_id],for_single_item_number:sozai_num_hash[product_id],
      for_sub_item_number:bento_fukusai_num_hash[product_id])
    end

    daily_menu.daily_menu_details.each do |dmd|
      if product_num_hash[dmd.product_id].present?
        dmd.for_single_item_number = sozai_num_hash[dmd.product_id]
        dmd.for_sub_item_number = bento_fukusai_num_hash[dmd.product_id]
        dmd.manufacturing_number = dmd.for_single_item_number + dmd.for_sub_item_number + dmd.adjustments
        update_dmds << dmd
      else
        dmd.for_single_item_number = 0
        dmd.for_sub_item_number = 0
        dmd.manufacturing_number = 0 + dmd.adjustments
        update_dmds << dmd
      end
      total_manufacturing_number += dmd.manufacturing_number
    end
    DailyMenuDetail.import update_dmds, on_duplicate_key_update:[:for_single_item_number,:for_sub_item_number,:manufacturing_number]
    daily_menu.update_attributes(total_manufacturing_number:total_manufacturing_number)
  end
  def self.upload_csv(file)
  end

end
