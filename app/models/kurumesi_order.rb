require 'selenium-webdriver'
class KurumesiOrder < ApplicationRecord
  has_many :kurumei_mails
  has_many :kurumesi_order_details, dependent: :destroy
  accepts_nested_attributes_for :kurumesi_order_details, allow_destroy: true

  belongs_to :brand

  validates :management_id, presence: true

  enum payment: {"請求書(持参)":0, "現金":1, "クレジットカード":2,"請求書（郵送）":3}

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
end
