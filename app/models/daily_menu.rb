require 'csv'
class DailyMenu < ApplicationRecord
  has_many :daily_menu_details, dependent: :destroy
  has_many :products, through: :daily_menu_details
  accepts_nested_attributes_for :daily_menu_details, allow_destroy: true
  has_many :store_daily_menus, dependent: :destroy

  validates :start_time, presence: true, uniqueness: true
  before_save :total_check
  after_save :input_stock
  after_destroy :input_stock
  after_update :update_sdmd_row_order


  def self.upload_data(file)
      new_dmds = []
      update_dmds = []
      # saved_smaregi_members = DailyMenuDetail.all.map{|sm|[sm.kaiin_id,sm]}.to_h
      # member_raiten_kaisu = SmaregiTradingHistory.where.not(kaiin_id:nil).where(torihikimeisai_id:1,uchikeshi_kubun:0).group(:kaiin_id).count
      dates = []
      CSV.foreach(file.path,liberal_parsing:true, headers: true) do |row|
        row = row.to_hash
        date = row["日付"]
        dates << date
      end
      dmd_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      DailyMenuDetail.joins(:daily_menu).where(:daily_menus => {start_time:dates}).each do |dmd|
        dmd_hash[dmd.daily_menu.start_time][dmd.paper_menu_number] = dmd
        dmd_hash[dmd.daily_menu.start_time]["daily_menu_id"] = dmd.daily_menu_id
      end

      CSV.foreach(file.path,liberal_parsing:true, headers: true) do |row|
        row = row.to_hash
        date = row["日付"].to_date
        if dmd_hash[date]['daily_menu_id'].present?
          [24,25,26,27,28,29].each do |paper_menu_number|
            product_id = row[paper_menu_number.to_s]
            dmd = dmd_hash[date][paper_menu_number]
            if product_id.present?
              product = Product.find(product_id)
              if product
                sell_price = product.sell_price
                if dmd.present?
                  dmd.product_id = product_id
                  update_dmds << dmd
                else
                  new_dmds << DailyMenuDetail.new(daily_menu_id:dmd_hash[date]['daily_menu_id'],product_id:product_id,paper_menu_number:paper_menu_number,sell_price:sell_price)
                end
              end
            end
          end
        end
      end
      DailyMenuDetail.import update_dmds, on_duplicate_key_update:[:product_id]
      DailyMenuDetail.import new_dmds
      return
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
  def self.store_order_close
    store_daily_menus_arr = []
    if Date.today.wday == 5
      dates = (Date.today+5..Date.today+7).to_a
    elsif Date.today.wday == 1
      dates = (Date.today+5..Date.today+8).to_a
    end
    store_ids = Group.find(29).stores.ids
    StoreDailyMenu.where(start_time:dates,store_id:store_ids).each do |sdm|
      sdm.editable_flag = false
      store_daily_menus_arr << sdm
    end
    StoreDailyMenu.import store_daily_menus_arr, on_duplicate_key_update:[:editable_flag] if store_daily_menus_arr.present?
  end


  def self.once_1month_create(params_date,store_ids)
    new_arr = []
    new_store_daily_menu_arr = []
    dates = (Date.parse(params_date).all_month)
    dates.each do |date|
      if DailyMenu.find_by(start_time:date).present?
      else
        new_arr << DailyMenu.new(start_time:date)
      end
    end
    DailyMenu.import new_arr if new_arr.present?
    daily_menus = DailyMenu.where(start_time:dates)
    daily_menus.each do |dm|
      created_store_ids = dm.store_daily_menus.map{|sdm|sdm.store_id.to_s}
      new_store_ids = store_ids - created_store_ids
      new_store_ids.each do |store_id|
        new_store_daily_menu_arr << StoreDailyMenu.new(start_time:dm.start_time,daily_menu_id:dm.id,store_id:store_id)
      end
    end
    StoreDailyMenu.import new_store_daily_menu_arr if new_store_daily_menu_arr.present?
  end

  def self.stock_reload(daily_menu)
    #saveされたdailymenuの日付を取得
    store_id = 39
    date = daily_menu.start_time
    previous_day = date - 1
    Stock.calculate_stock(date,previous_day,store_id)
    daily_menu.update_column(:stock_update_flag,false)
  end

  def total_check
    self.daily_menu_details.each do |dmd|
      dmd.manufacturing_number = dmd.for_single_item_number + dmd.for_sub_item_number + dmd.adjustments
    end
  end

end
