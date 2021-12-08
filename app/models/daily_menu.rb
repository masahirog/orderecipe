require 'csv'
class DailyMenu < ApplicationRecord
  has_many :daily_menu_details, dependent: :destroy
  has_many :products, through: :daily_menu_details
  accepts_nested_attributes_for :daily_menu_details, allow_destroy: true
  has_many :store_daily_menus

  validates :start_time, presence: true, uniqueness: true
  before_save :total_check
  after_save :input_stock
  after_destroy :input_stock

  def self.once_1month_create(params_date)
    new_arr = []
    (Date.parse(params_date).all_month).each do |date|
      if DailyMenu.find_by(start_time:date).present?
      else
        new_arr << DailyMenu.new(start_time:date)
      end
    end
    DailyMenu.import new_arr if new_arr.present?
  end
  def self.upload_menu(file)
    dates = []
    hash = {}
    daily_menu_hash = {}
    count = 0
    CSV.foreach(file.path,liberal_parsing:true, headers: true) do |row|
      row = row.to_hash
      dates <<  row["date"] if row["date"].present?
    end
    dates = dates.uniq
    daily_menus = DailyMenu.where(start_time:dates)
    daily_menu_details = DailyMenuDetail.where(id:daily_menus.ids).map{}
    hash = daily_menus.map{|daily_menu|[daily_menu.start_time.to_s,daily_menu.id]}.to_h
    create_daily_menu_details_arr = []
    update_daily_menu_details_arr = []
    CSV.foreach(file.path,liberal_parsing:true, headers: true) do |row|
      date = row["date"].gsub('/','-')
      product_id = row["product_id"]
      sub_num = row["sub_num"].to_i
      dmd = DailyMenuDetail.find_by(daily_menu_id:hash[date],product_id:product_id)
      if dmd.present?
        dmd.for_sub_item_number = row["sub_num"].to_i
        dmd.manufacturing_number = dmd.for_single_item_number + sub_num
        update_daily_menu_details_arr << dmd
      else
        create_daily_menu_details_arr << DailyMenuDetail.new(daily_menu_id:hash[date],product_id:product_id,for_sub_item_number:sub_num,manufacturing_number:sub_num)
      end
    end
    DailyMenuDetail.import create_daily_menu_details_arr if create_daily_menu_details_arr.present?
    DailyMenuDetail.import update_daily_menu_details_arr, on_duplicate_key_update:[:for_sub_item_number] if update_daily_menu_details_arr.present?

  end

  def total_check
    self.daily_menu_details.each do |dmd|
      dmd.manufacturing_number = dmd.for_single_item_number + dmd.for_sub_item_number + dmd.adjustments
    end
  end

  def input_stock
    #saveされたdailymenuの日付を取得
    date = self.start_time
    previous_day = self.start_time - 1
    Stock.calculate_stock(date,previous_day)
  end
end
