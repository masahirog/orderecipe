require 'nokogiri'
require 'mechanize'

class KurumesiOrder < ApplicationRecord
  has_many :kurumesi_mails
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


  def self.pick_time_scraping
    date = Date.tomorrow
    year = date.year
    month = date.month
    day = date.day
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari 4'
    agent.get('http://admin.kurumesi-bentou.com/admin_shop/') do |page|
      mypage = page.form_with(name:'form1') do |form|
        # ログインに必要な入力項目を設定していく
        # formオブジェクトが持っている変数名は入力項目(inputタグ)のname属性
        form.shop_id = '759'
        form.shop_pass = 'bchimBS9'
      end.submit
      taget_url = "http://admin.kurumesi-bentou.com/admin_shop/order/?action=SearchOrder&delivery_yy_s=#{year}&delivery_mm_s=#{month}&delivery_dd_s=#{day}&delivery_yy_e=#{year}&delivery_mm_e=#{month}&delivery_dd_e=#{day}&order_status=1"
      html = agent.get(taget_url).content
      contents = Nokogiri::HTML(html, nil, 'utf-8')
      kurumesi_orders_arr = []
      contents.search(".detail").each do |content|
        hour = ""
        minute = ""
        pick_time = ""
        kurumesi_order_id = content.at(".boxTtl h2").inner_text[4..11]
        kurumesi_order = KurumesiOrder.find_by(management_id:kurumesi_order_id)
        if kurumesi_order.present?
          content.search("//*[@id='form_#{kurumesi_order_id}']/select[2]/option").to_a.each do |aa|
            if aa.to_a[1].present?
              hour = aa.to_h['value']
              content.search("//*[@id='form_#{kurumesi_order_id}']/select[3]/option").to_a.each do |aa|
                if aa.to_a[1].present?
                  minute = aa.to_h['value']
                  pick_time = hour + ":" + minute
                  break
                end
              end
              break
            end
          end
          kurumesi_order.pick_time = pick_time
          kurumesi_orders_arr << kurumesi_order
        end
      end
      KurumesiOrder.import kurumesi_orders_arr, on_duplicate_key_update: [:pick_time]
    end
  end
  # def self.capture_check
  #   # Dotenv.overload
  #   s3 = Aws::S3::Resource.new(
  #     region: 'ap-northeast-1',
  #     credentials: Aws::Credentials.new(
  #       ENV['ACCESS_KEY_ID'],
  #       ENV['SECRET_ACCESS_KEY']
  #     )
  #   )
  #   date = Date.today
  #   kurumesi_orders = KurumesiOrder.where("start_time >= ?",date).where(canceled_flag:false)
  #   arr = []
  #   kurumesi_orders.each_with_index do |ko,i|
  #     p i
  #     unless s3.bucket('kurumesi-check').object("#{ko.management_id}.jpg").exists?
  #       ko.capture_done = false
  #       arr << ko
  #     end
  #   end
  #   KurumesiOrder.import arr, on_duplicate_key_update:[:capture_done] if arr.present?
  # end


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
          if num > 150
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
        if num > 150
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
    NotificationMailer.send_kurumesi_capa_notice(date,num).deliver
    # line_notify = LineNotify.new('HphDLztqtfKtGvUv918Q2cOxZaeW513ujIEK1l3wL6a')
    # options = {
    #   message: "\n#{date}の製造数が#{num}個になりました！"
    # }
    # line_notify.ping(options)
  end
end
