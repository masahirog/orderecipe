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

  def self.upload_sales_data(file,store_daily_menu_id)
    store_daily_menu = StoreDailyMenu.find(store_daily_menu_id)
    hash = {}
    update_datas = []
    count = 0
    CSV.foreach(file.path,liberal_parsing:true, headers: true) do |row|
      row = row.to_hash
      if row["品番"].present?
        product_id = row["品番"].to_i
        sales_num = row["実販売点数"].to_i
        hash[product_id] = sales_num
      end
    end
    store_daily_menu.store_daily_menu_details.each do |sdmd|
      product_id = sdmd.product_id
      if hash[product_id]
        sdmd.sales_number = hash[product_id]
        update_datas << sdmd
      end
    end
    StoreDailyMenuDetail.import update_datas, on_duplicate_key_update:[:sales_number] if update_datas.present?
    return (update_datas.count)
  end

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
    daily_menu.daily_menu_details.each do |dmd|
      if product_num_hash[dmd.product_id].present?
        dmd.for_single_item_number = product_num_hash[dmd.product_id]
        dmd.manufacturing_number = dmd.for_single_item_number + dmd.for_sub_item_number
        dmd.for_single_item_number = product_num_hash[dmd.product_id]
        dmd.manufacturing_number = dmd.for_single_item_number + dmd.for_sub_item_number
        update_dmds << dmd
        total_manufacturing_number = dmd.manufacturing_number
      end
    end
    DailyMenuDetail.import update_dmds, on_duplicate_key_update:[:for_single_item_number,:manufacturing_number]
    daily_menu.update_attributes(total_manufacturing_number:total_manufacturing_number)
  end


end
