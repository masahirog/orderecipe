class KurumesiOrder < ApplicationRecord
  has_many :kurumei_mails
  has_many :kurumesi_order_details, dependent: :destroy
  accepts_nested_attributes_for :kurumesi_order_details, allow_destroy: true

  validates :management_id, presence: true

  enum payment: {請求書:0, 現金:1, クレジットカード:2}

  after_save :input_stock

  def input_stock
    #saveされたdailymenuの日付を取得
    date = self.start_time
    previous_day = self.start_time - 1
    Stock.calculate_stock(date,previous_day)
  end
end
