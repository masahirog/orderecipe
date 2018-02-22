class Material < ApplicationRecord
  # has_paper_trail

  has_many :menu_materials, dependent: :destroy
  has_many :menus, through: :menu_materials

  has_many :order_materials, dependent: :destroy
  has_many :orders, through: :order_materials

  belongs_to :vendor

  # after_save :update_cache

  validates :name, presence: true, uniqueness: true, format: { with:/\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  validates :order_name, presence: true, format: { with:/\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  validates :calculated_value, presence: true, numericality: true
  validates :order_unit_quantity, presence: true, numericality: true
  validates :calculated_unit, presence: true
  validates :calculated_price, presence: true, numericality: true
  validates :cost_price, presence: true, numericality: true
  validates :vendor_id, presence: true

  def self.search(params)
   if params
     data = Material.order(id: "DESC").all
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data = data.where(['order_name LIKE ?', "%#{params["order_name"]}%"]) if params["order_name"].present?
     data = data.where(vendor_id: params["vendor_id"]) if params["vendor_id"].present?
     data = data.where(['order_code LIKE ?', "%#{params["order_code"]}%"]) if params["order_code"].present?
     data = data.where(['end_of_sales LIKE ?', "%#{params["end_of_sales"]["value"]}%"]) if params["end_of_sales"].present?
     data
   else
     Material.order(id: "DESC").all
   end
  end

  def self.calculate_products_materials(params)
    hoge = []
    for i in 0..5
      if params["id#{i}"].present?
        Product.includes(:product_menus,[menus: [menu_materials: :material]]).find(params["id#{i}"]).menus.each do |menu|
          menu.menu_materials.each do |menu_material|
            #その他、ヒロセ米穀、折兼の3件は表示しない
            if menu_material.material.vendor_id == 111 || menu_material.material.vendor_id == 171 || menu_material.material.vendor_id == 21
            else
              hash={}
              hash.store("material_id", menu_material.material_id)
              hash.store("amount_used", menu_material.amount_used.to_f * params["num#{i}"].to_i)
              hash.store("vendor_id", menu_material.material.vendor_id)
              hoge << hash
            end
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
    order = Order.includes(order_materials: :material).find(params[:id])
    ordermaterials = order.order_materials
    materials_this_vendor = []
    pvi = params[:vendor][:id].to_i
    ordermaterials.each do |om|
      vendorid = om.material.vendor_id
      if pvi == vendorid
        materials_this_vendor << om
      end
    end
    return materials_this_vendor
    # order = Order.find(params[:id])
    # materials_this_vendor = order.materials.where(vendor_id:params[:vendor][:id])
    # return materials_this_vendor

  end

  private
  # def update_cache
  #   menu_materials = MenuMaterial.where( material_id: self.id )
  #   menu_materials.each do |menu_material|
  #     id = menu_material.menu_id
  #     menu_materials = MenuMaterial.where(menu_id: id)
  #     kingaku = 0
  #     menu_materials.each do |mm|
  #       used = mm.amount_used
  #       cost = mm.material.cost_price
  #       price = used * cost
  #       kingaku = kingaku + price
  #     end
  #     cost_price = kingaku.round(2)
  #     menu = Menu.find(id)
  #     menu.update(cost_price: kingaku)
  #   end
  # end
end
