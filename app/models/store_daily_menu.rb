require 'csv'
class StoreDailyMenu < ApplicationRecord
  belongs_to :daily_menu
  belongs_to :store
  has_many :store_daily_menu_details, ->{order("row_order") }, dependent: :destroy
  has_many :products, through: :store_daily_menu_details
  accepts_nested_attributes_for :store_daily_menu_details, allow_destroy: true
  has_many :store_daily_menu_photos, dependent: :destroy
  accepts_nested_attributes_for :store_daily_menu_photos

  enum weather: {sunny:1, cloud:2,rain:3,strong_rain:4,taihoon:5,snow:6}
  validates :daily_menu_id, :uniqueness => {:scope => :store_id}

  before_save :total_check
  after_update :input_stock
  after_destroy :input_stock


  #納品量の追加
  def total_check
    self.store_daily_menu_details.each do |sdmd|
      sdmd.actual_inventory = sdmd.number + sdmd.stock_deficiency_excess - sdmd.carry_over
    end
  end

  def input_stock
    update_dmds = []
    total_manufacturing_number = 0
    daily_menu = self.daily_menu
    sdmds = StoreDailyMenuDetail.where(store_daily_menu_id:daily_menu.store_daily_menus.ids)
    product_num_hash = sdmds.group(:product_id).sum(:number)

    dmdps = daily_menu.daily_menu_details.pluck(:product_id).uniq
    sdmdps = sdmds.pluck(:product_id).uniq
    (sdmdps - dmdps).each do |product_id|
      DailyMenuDetail.create(daily_menu_id:daily_menu.id,product_id:product_id,manufacturing_number:product_num_hash[product_id],for_single_item_number:product_num_hash[product_id])
    end

    daily_menu.daily_menu_details.each do |dmd|
      if product_num_hash[dmd.product_id].present?
        dmd.for_single_item_number = product_num_hash[dmd.product_id]
        dmd.manufacturing_number = dmd.for_single_item_number + dmd.for_sub_item_number
        update_dmds << dmd
      else
        dmd.for_single_item_number = 0
        dmd.manufacturing_number = dmd.for_sub_item_number
        update_dmds << dmd
      end
      total_manufacturing_number += dmd.manufacturing_number
    end
    DailyMenuDetail.import update_dmds, on_duplicate_key_update:[:for_single_item_number,:manufacturing_number]
    daily_menu.update_attributes(total_manufacturing_number:total_manufacturing_number)
  end
  def self.upload_csv(file)
  end

end
