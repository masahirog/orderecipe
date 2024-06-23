class DailyMenuDetail < ApplicationRecord
  belongs_to :daily_menu,optional:true
  belongs_to :product
  belongs_to :serving_plate
  has_many :temporary_product_menus

  before_create :calculate_cost_price
  before_update :calculate_total_cost_price
  before_update :product_change
  validates :daily_menu_id, :uniqueness => {:scope => :product_id}
  after_destroy :store_daily_menu_detail_destroy

  def calculate_cost_price
    per_cost = self.product.cost_price
    self.cost_price_per_product = per_cost
    num = self.manufacturing_number
    total_cost = (per_cost * num).round
    self.total_cost_price = total_cost
  end

  def calculate_total_cost_price
    per_cost = self.cost_price_per_product
    num = self.manufacturing_number
    total_cost = (per_cost * num).round
    self.total_cost_price = total_cost
  end
  def store_daily_menu_detail_destroy
    store_daily_menu_ids = self.daily_menu.store_daily_menus.ids
    StoreDailyMenuDetail.where(store_daily_menu_id:store_daily_menu_ids,product_id:self.product_id).destroy_all
  end

  def product_change
    product_id_was = self.product_id_was
    product_id = self.product_id
    if product_id_was == product_id
    else
      store_daily_menu_ids = self.daily_menu.store_daily_menus.ids
      store_daily_menu_details = StoreDailyMenuDetail.where(store_daily_menu_id:store_daily_menu_ids,product_id:product_id_was)
      store_daily_menu_details.update_all(product_id: product_id)
    end
  end
end
