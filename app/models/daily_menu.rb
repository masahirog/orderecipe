class DailyMenu < ApplicationRecord
  has_many :daily_menu_details, ->{order("row_order") }, dependent: :destroy
  accepts_nested_attributes_for :daily_menu_details, allow_destroy: true

  after_save :input_stock
  #納品量の追加

  def input_stock
    #saveされたdailymenuの日付を取得
    date = self.start_time
    Stock.calculate_stock(date)
  end
end
