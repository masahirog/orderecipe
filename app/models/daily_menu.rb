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
  after_update :update_sdmd_row_order

  def self.once_1month_create(params_date)
    new_arr = []
    new_store_daily_menu_arr = []
    dates = []
    (Date.parse(params_date).all_month).each do |date|
      if DailyMenu.find_by(start_time:date).present?
      else
        new_arr << DailyMenu.new(start_time:date)
        dates << date
      end
    end
    DailyMenu.import new_arr if new_arr.present?

    DailyMenu.where(start_time:dates).each do |date|
      if DailyMenu.find_by(start_time:date).present?
      else
        new_store_daily_menu_arr << StoreDailyMenu.new(start_time:date)
      end
    end
    StoreDailyMenu.import new_store_daily_menu_arr if new_store_daily_menu_arr.present?
  end
  def self.upload_menu(file)
    dates = []
    hash = {}
    daily_menu_hash = {}
    count = 0
    i = 0
    CSV.foreach(file.path,liberal_parsing:true, headers: true) do |row|
      row = row.to_hash
      dates <<  row["date"] if row["date"].present?
      if i == 0
        @store_ids = row.keys - ["date", "product_id", "row_order", "serving_plate_id", "showcase_type","sub_num"]
      end
      i = 1
    end
    dates = dates.uniq
    daily_menus = DailyMenu.where(start_time:dates)
    daily_menu_details = DailyMenuDetail.where(id:daily_menus.ids).map{}
    hash = daily_menus.map{|daily_menu|[daily_menu.start_time.to_s,daily_menu.id]}.to_h
    create_daily_menu_details_arr = []
    update_daily_menu_details_arr = []
    sdm_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    CSV.foreach(file.path,liberal_parsing:true, headers: true) do |row|
      date = row["date"].gsub('/','-')
      product_id = row["product_id"]
      product = Product.find(product_id)
      sub_num = row["sub_num"].to_i
      row_order = row["row_order"].to_i
      dmd = DailyMenuDetail.find_by(daily_menu_id:hash[date],product_id:product_id)
      @store_ids.each do |store_id|
        sdm_hash[date][product_id][store_id][:sub_num] = row[store_id]
        sdm_hash[date][product_id][store_id][:showcase_type] = row["showcase_type"]
        sdm_hash[date][product_id][store_id][:serving_plate_id] = row["serving_plate_id"]
        sdm_hash[date][product_id][store_id][:row_order] = row["row_order"]
      end
      if dmd.present?
        dmd.for_sub_item_number = sub_num
        dmd.manufacturing_number = dmd.for_single_item_number + sub_num
        dmd.row_order = row_order
        update_daily_menu_details_arr << dmd
      else
        create_daily_menu_details_arr << DailyMenuDetail.new(daily_menu_id:hash[date],product_id:product_id,for_sub_item_number:sub_num,manufacturing_number:sub_num,row_order:row_order,sell_price:product.sell_price)
      end
    end
    DailyMenuDetail.import create_daily_menu_details_arr if create_daily_menu_details_arr.present?
    DailyMenuDetail.import update_daily_menu_details_arr, on_duplicate_key_update:[:for_sub_item_number,:row_order] if update_daily_menu_details_arr.present?
    store_daily_menu_details_arr = []
    daily_menus.each do |dm|
      @store_ids.each do |store_id|
        store_daily_menu = StoreDailyMenu.find_by(daily_menu_id:dm.id,store_id:store_id)
        if store_daily_menu.present?
        else
          store_daily_menu = StoreDailyMenu.create(daily_menu_id:dm.id,store_id:store_id,start_time:dm.start_time)
        end
        if store_daily_menu.store_daily_menu_details.present?
          sdmd_product_ids = store_daily_menu.store_daily_menu_details.map{|sdmd|sdmd.product_id}
          dmd_product_ids = dm.daily_menu_details.map{|dmd|dmd.product_id}
          add_product_ids = dmd_product_ids - sdmd_product_ids
          dmds = dm.daily_menu_details.where(product_id:add_product_ids)
        else
          dmds = dm.daily_menu_details
        end
        dmds.each do |dmd|
          sub_num = sdm_hash[dm.start_time.to_s][dmd.product_id.to_s][store_id][:sub_num]
          showcase_type = sdm_hash[dm.start_time.to_s][dmd.product_id.to_s][store_id][:showcase_type]
          serving_plate_id = sdm_hash[dm.start_time.to_s][dmd.product_id.to_s][store_id][:serving_plate_id]
          row_order = sdm_hash[dm.start_time.to_s][dmd.product_id.to_s][store_id][:row_order]
          price = dmd.product.sell_price
          store_daily_menu_details_arr << StoreDailyMenuDetail.new(store_daily_menu_id:store_daily_menu.id,product_id:dmd.product_id,row_order:row_order,
            bento_fukusai_number:sub_num,showcase_type:showcase_type,serving_plate_id:serving_plate_id,price:price)
        end
      end
    end
    StoreDailyMenuDetail.import store_daily_menu_details_arr

  end

  def total_check
    self.daily_menu_details.each do |dmd|
      dmd.manufacturing_number = dmd.for_single_item_number + dmd.for_sub_item_number + dmd.adjustments
    end
  end

  def input_stock
    #saveされたdailymenuの日付を取得
    store_id = 39
    date = self.start_time
    previous_day = self.start_time - 1
    Stock.calculate_stock(date,previous_day,store_id)
  end
  def update_sdmd_row_order
    hash = self.daily_menu_details.map{|dmd|[dmd.product_id,dmd.row_order]}.to_h
    update_sdmds = []
    store_daily_menus = self.store_daily_menus
    store_daily_menus.each do |sdm|
      sdm.store_daily_menu_details.each do |sdmd|
        sdmd.row_order = hash[sdmd.product_id]
        update_sdmds << sdmd
      end
    end
    StoreDailyMenuDetail.import update_sdmds, on_duplicate_key_update:[:row_order]
  end
end
