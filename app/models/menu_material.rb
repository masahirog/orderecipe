class MenuMaterial < ApplicationRecord
  has_paper_trail

  belongs_to :menu
  belongs_to :material

  validates :amount_used, presence: true, format: { :with=>/\A\d+(\.)?+(\d){0,3}\z/,
    message: "：小数点3位までの値が入力できます" }, numericality: true
  validates :material_id, presence: true

  after_save :update_cache

  private
  def update_cache
    menu = Menu.find(self.menu_id)
    kingaku = 0
    menu.menu_materials.each do |mm|
      used = mm.amount_used
      cost = mm.material.cost_price
      price = used * cost
      kingaku = kingaku + price
    end
    cost_price = kingaku.round(2)
    menu.update(cost_price: kingaku)
  end
end
