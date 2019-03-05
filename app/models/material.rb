class Material < ApplicationRecord
  serialize :allergy
  has_many :menu_materials, dependent: :destroy
  has_many :menus, through: :menu_materials

  has_many :order_materials, dependent: :destroy
  has_many :orders, through: :order_materials

  has_many :food_additives, through: :material_food_additives
  has_many :material_food_additives
  accepts_nested_attributes_for :material_food_additives, allow_destroy: true, :reject_if => :reject_additives

  belongs_to :vendor
  scope :mate_search, lambda { |query|  where(end_of_sales:0).where('name LIKE ?', "%#{query}%").limit(100)}


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

  def self.calculate_products_materials(order_info)
    hoge = []
    binding.pry
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
              hash.store("product_id", Product.find(params["id#{i}"]).id)
              hoge << hash
            end
          end
        end
      end
    end
    hoge.sort! do |a, b|
      a["vendor_id"] <=> b["vendor_id"]
    end
    ar = hoge.group_by{|name|name.values[0]}
    return ar
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

  def self.change_additives(material_ids)
    ar =[]
    material_ids.each do |id|
      arr=[]
      if Material.find(id).material_food_additives.present?
        Material.find(id).material_food_additives .each do |material_food_additive|
          arr << {"text" => material_food_additive.food_additive.name, "id" => material_food_additive.food_additive_id}
        end
        hash = { "text" => Material.find(id).name,"children" =>arr}
        ar << hash
      else
      end
    end
    @ar = ar
  end

  def reject_additives(attributed)
     attributed['food_additive_id'].blank?
  end
  private

end
