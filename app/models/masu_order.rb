class MasuOrder < ApplicationRecord
  has_many :kurumei_mails
  has_many :masu_order_details, dependent: :destroy
  accepts_nested_attributes_for :masu_order_details, allow_destroy: true

  validates :kurumesi_order_id, presence: true, uniqueness: true

  enum payment: {請求書:0, 現金:1, クレジットカード:2}
  enum miso: {なし:0, あり:1}
  enum tea: {不要:0, PET:1, 缶:2}

  after_save :input_stock

  def input_stock
    #saveされたdailymenuの日付を取得
    date = self.start_time
    Stock.calculate_stock(date)
  end
end
