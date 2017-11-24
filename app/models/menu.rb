class Menu < ApplicationRecord
  has_paper_trail
  has_many :menu_materials, dependent: :destroy
  has_many :materials, through: :menu_materials
  accepts_nested_attributes_for :menu_materials, allow_destroy: true, update_only: true
  has_many :product_menus, dependent: :destroy
  has_many :products, through: :product_menus

  after_update :update_product_cost_price

  validates :name, presence: true, uniqueness: true, format: { with:/\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  validates :category, presence: true
  validates :cost_price, presence: true, numericality: true

  def self.search(params)
   if params
     data = Menu.order(id: "DESC").all
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data = data.where(category: params["category"]) if params["category"].present?
     data
   else
     Menu.order(id: "DESC").all
   end
  end


  def self.menu_materials_info(params)
    menu = Menu.find(params[:id])
    hoge = []
    menu.menu_materials.each do |mm|
      hash = {}
      hash.store("material_name", mm.material.name)
      hash.store("material_cost_price", mm.material.cost_price)
      hash.store("amount_used", mm.amount_used)
      hash.store("calculated_unit", mm.material.calculated_unit)
      hash.store("preparation", mm.preparation)
      hoge << hash
    end
    return hoge
  end

  private
  def update_product_cost_price
    product_menus_selected_menu = ProductMenu.where( menu_id: self.id )
    product_menus_selected_menu.each do |pmsm|
      id = pmsm.product_id
      product_menus = ProductMenu.where(product_id: id)
      kingaku = 0
      product_menus.each do |pm|
        kingaku += pm.menu.cost_price
      end
      cost_price = (kingaku * 1.08).round(1)
      Product.find(id).update(cost_price: cost_price)
    end
  end
end
