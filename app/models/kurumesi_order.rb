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
end
