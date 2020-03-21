class KurumesiOrder < ApplicationRecord
  has_many :kurumei_mails
  has_many :kurumesi_order_details, dependent: :destroy
  accepts_nested_attributes_for :kurumesi_order_details, allow_destroy: true

  belongs_to :brand

  validates :management_id, presence: true

  enum payment: {請求書（持参）:0, 現金:1, クレジットカード:2,請求書（郵送）:3}

  # 在庫に関する部分が動いた時だけ、在庫の計算を行う
  before_save :changed_check
  after_save :input_stock

  def input_stock
    if @change_flag == true
      #saveされたdailymenuの日付を取得
      date = self.start_time
      previous_day = self.start_time - 1
      Stock.calculate_stock(date,previous_day)
    end
  end

  def changed_check
    @change_flag = false
    if self.canceled_flag_changed? ||self.start_time_changed?
      @change_flag = true
    else
      self.kurumesi_order_details.each do |kod|
        @change_flag = true if kod.changed? || kod.marked_for_destruction?
      end
    end
  end

  def self.capture_check
    # Dotenv.overload
    s3 = Aws::S3::Resource.new(
      region: 'ap-northeast-1',
      credentials: Aws::Credentials.new(
        ENV['ACCESS_KEY_ID'],
        ENV['SECRET_ACCESS_KEY']
      )
    )
    date = Date.today
    kurumesi_orders = KurumesiOrder.where("start_time >= ?",date).where(canceled_flag:false)
    arr = []
    kurumesi_orders.each_with_index do |ko,i|
      p i
      unless s3.bucket('kurumesi-check').object("#{ko.management_id}.jpg").exists?
        ko.capture_done = false
        arr << ko
      end
    end
    KurumesiOrder.import arr, on_duplicate_key_update:[:capture_done] if arr.present?
  end


  def self.capacity_check
    new_arr = []
    update_arr = []
    kurumesi_orders = KurumesiOrder.where('start_time >= ?',Date.today).where(canceled_flag:false)
    kurumesi_order_details = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {id:kurumesi_orders.ids})
    date_numbers = kurumesi_order_details.where(:products => {product_category:1}).group('kurumesi_orders.start_time').sum(:number)
    date_manufacture_numbers = DateManufactureNumber.where('date >= ?',Date.today)
    dmf_hash = date_manufacture_numbers.map{|dmf|[dmf.date,dmf]}.to_h
    date_numbers.each do |date,num|
      dmf = dmf_hash[date]
      if dmf.present?
        if num == dmf.num
        else
          if num > 400
            if dmf.notified_flag == true
              dmf.num = num
            else
              dmf.num = num
              dmf.notified_flag = true
              capacity_notify(date,num)
            end
          else
            dmf.num = num
          end
          update_arr << dmf
        end
      else
        if num > 400
          new_arr << DateManufactureNumber.new(date:date,num:num,notified_flag:true)
          capacity_notify(date,num)
        else
          new_arr << DateManufactureNumber.new(date:date,num:num)
        end
      end
    end
    DateManufactureNumber.import new_arr if new_arr.present?
    DateManufactureNumber.import update_arr, on_duplicate_key_update:[:num,:notified_flag] if update_arr.present?
  end

  def self.capacity_notify(date,num)
    line_notify = LineNotify.new('i061vPP7Fqs02DnIxMMEVoYRXV04N61k62ohDP7rRPw')
    options = {
      message: "\n#{date}の製造数が#{num}個になりました！"
    }
    line_notify.ping(options)
  end
end
