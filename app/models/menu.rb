class Menu < ApplicationRecord
  has_many :menu_materials, dependent: :destroy
  has_many :materials, through: :menu_materials
  accepts_nested_attributes_for :menu_materials, allow_destroy: true, update_only: true
  has_many :product_menus, dependent: :destroy
  has_many :products, through: :product_menus

  after_update :update_product_cost_price

  validates :name, presence: true, uniqueness: true, format: { with: /\A[\A[0-9a-zA-Zぁ-んァ-ンー-龥:\(\)、\/]+\z]+\z/,
    message: "：全角 [かな、カナ、漢字、句点]　　半角 [英数字、括弧、スラッシュ] が使用可能です"}
  validates :category, presence: true
  validates :cost_price, presence: true, numericality: true

  def self.search(params) #self.でクラスメソッドとしている
   if params # 入力がある場合の処理
     data = Menu.all
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data = data.where(category: params["category"]) if params["category"].present?
     data
   else
     Menu.all   # 全て表示する
   end
  end


  def self.menu_materials_info(params)
    menu = Menu.find(params[:id])
    hoge = []
    menu.menu_materials.each do |mm|
      hash = {}
      hash.store("material_name", mm.material.name)
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
