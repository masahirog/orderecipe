class DailyMenuDetail < ApplicationRecord
  belongs_to :daily_menu,optional:true
  belongs_to :product

  before_create :calculate_cost_price
  before_update :calculate_total_cost_price

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
end
