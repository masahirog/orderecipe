class Material < ApplicationRecord
  has_paper_trail

  has_many :menu_materials, dependent: :destroy
  has_many :menus, through: :menu_materials

  has_many :order_materials, dependent: :destroy
  has_many :orders, through: :order_materials

  belongs_to :vendor
  after_save :update_cache
  validates :name, presence: true, uniqueness: true, format: { with:/\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  validates :order_name, presence: true, format: { with:/\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  validates :calculated_value, presence: true, numericality: true
  validates :calculated_unit, presence: true
  validates :calculated_price, presence: true, numericality: true
  validates :cost_price, presence: true, numericality: true
  validates :vendor_id, presence: true

  def self.search(params) #self.でクラスメソッドとしている
   if params # 入力がある場合の処理
     data = Material.all
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data = data.where(['order_name LIKE ?', "%#{params["order_name"]}%"]) if params["order_name"].present?
     data = data.where(vendor_id: params["vendor_id"]) if params["vendor_id"].present?
     data = data.where(['order_code LIKE ?', "%#{params["order_code"]}%"]) if params["order_code"].present?
     data = data.where(['end_of_sales LIKE ?', "%#{params["end_of_sales"]["value"]}%"]) if params["end_of_sales"].present?
     data
   else
     Material.all   # 全て表示する
   end
  end

  def self.calculate_products_materials(params)
    hoge = []
    for i in 0..3
      if params["id#{i}"].present?
        Product.find(params["id#{i}"]).menus.each do |menu|
          menu.menu_materials.each do |menu_material|
              hash={}
              hash.store("material_id", menu_material.material_id)
              hash.store("amount_used", menu_material.amount_used.to_f * params["num#{i}"].to_i)
              hash.store("vendor_id", menu_material.material.vendor_id)
              hoge << hash
          end
        end
      end
    end
    fuga = []
    hoge.each_with_object({}) do | h, obj |
     obj[h["material_id"]] ||= { "amount_used" =>  0}
     obj[h["material_id"]]["amount_used"] += h["amount_used"]
     obj[h["material_id"]]["vendor_id"] = h["vendor_id"]
     fuga = obj.map{|k, v| {"material_id"=> k}.merge(v)}
    end
    fuga.sort! do |a, b|
      a["vendor_id"] <=> b["vendor_id"]
    end
    return fuga
  end

  def self.get_material_this_vendor(params)
    order = Order.find(params[:id])
    materials_this_vendor = order.materials.where(vendor_id:params[:vendor][:id])
    return materials_this_vendor
  end

  private
  def update_cache
    menu_materials = MenuMaterial.where( material_id: self.id )
    menu_materials.each do |menu_material|
      id = menu_material.menu_id
      menu_materials = MenuMaterial.where(menu_id: id)
      kingaku = 0
      menu_materials.each do |mm|
        used = mm.amount_used
        cost = mm.material.cost_price
        price = used * cost
        kingaku = kingaku + price
      end
      cost_price = kingaku.round(2)
      menu = Menu.find(id)
      menu.update(cost_price: kingaku)
    end
  end
end
