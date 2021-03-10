class DailyMenu < ApplicationRecord
  has_many :daily_menu_details, ->{order("row_order") }, dependent: :destroy
  has_many :products, through: :daily_menu_details
  accepts_nested_attributes_for :daily_menu_details, allow_destroy: true
  has_many :daily_menu_photos, dependent: :destroy
  accepts_nested_attributes_for :daily_menu_photos
  has_many :store_daily_menus

  validates :start_time, presence: true, uniqueness: true
  before_save :total_check
  after_save :input_stock
  after_destroy :input_stock
  enum weather: {sunny:1, cloud:2,rain:3,strong_rain:4,taihoon:5,snow:6}
  #納品量の追加

  def total_check
    self.daily_menu_details.each do |dmd|
      dmd.manufacturing_number = dmd.for_single_item_number + dmd.for_sub_item_number
    end
  end

  def input_stock
    #saveされたdailymenuの日付を取得
    date = self.start_time
    previous_day = self.start_time - 1
    Stock.calculate_stock(date,previous_day)
  end

end
