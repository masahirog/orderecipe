class Material < ApplicationRecord
  # 単価は税抜ですべて保存する、表示時に税追加
  has_many :material_cut_patterns, dependent: :destroy
  accepts_nested_attributes_for :material_cut_patterns, allow_destroy: true

  has_many :material_store_orderables, dependent: :destroy
  accepts_nested_attributes_for :material_store_orderables, allow_destroy: true

  serialize :allergy
  has_many :menu_materials, dependent: :destroy
  has_many :menus, through: :menu_materials

  has_many :order_materials, dependent: :destroy
  has_many :orders, through: :order_materials

  has_many :food_additives, through: :material_food_additives
  has_many :material_food_additives
  accepts_nested_attributes_for :material_food_additives, allow_destroy: true, :reject_if => :reject_additives

  belongs_to :vendor
  scope :mate_search, lambda { |query|  where(unused_flag:false).where('name LIKE ?', "%#{query}%").limit(100)}
  has_many :stocks
  mount_uploader :image, MaterialImageUploader

  # after_save :update_cache
  validates :name, presence: true, uniqueness: true, format: { with:/\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  validates :order_name, presence: true, format: { with:/\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  validates :recipe_unit_quantity, presence: true, numericality: true
  validates :order_unit_quantity, presence: true, numericality: true
  validates :recipe_unit, presence: true
  validates :recipe_unit_price, presence: true, numericality: true
  validates :cost_price, presence: true, numericality: true
  validates :vendor_id, presence: true
  validates :accounting_unit, presence: true
  validates :accounting_unit_quantity, presence: true

  enum category: {meat:1,vege:2,other_food:3,packed:4,consumable_item:5,cooking_item:6}
  enum storage_place: {un_saved:0,normal:1,refrigerate:2,freezing:3,pack:4,equipment:5}

  def self.search(params)
   if params
     if params['order_quantity_order'] == 'true'
       ids = OrderMaterial.joins(:order).where(orders:{fixed_flag:1}).where(delivery_date:(Date.today - 31)..Date.today).group(:material_id).sum(:order_quantity).transform_values(&:to_f).sort {|a,b| b[1]<=>a[1]}.to_h.keys
       data = Material.where(id:ids)
     else
      data = Material.order(id: "DESC").all
     end
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data = data.where(vendor_id: params["vendor_id"]) if params["vendor_id"].present?
     data = data.where(unused_flag:params["unused_flag"]) if params["unused_flag"].present?
     data
   else
     Material.order(id: "DESC").all
   end
  end

  def self.calculate_products_materials(order_info)
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

  def self.get_material_this_vendor(order_id,vendor_id)
    order = Order.includes(order_materials: :material).find(order_id)
    ordermaterials = order.order_materials.where(un_order_flag:false).joins(:material).order('materials.order_code asc')
    materials_this_vendor = []
    ordermaterials.each do |om|
      if vendor_id.to_i == om.material.vendor_id
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
