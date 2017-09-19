class Material < ApplicationRecord
  has_many :menu_materials, dependent: :destroy
  has_many :menus, through: :menu_materials

  belongs_to :vendor
  after_save :update_cache

  validates :name, presence: true, uniqueness: true
  validates :order_name, presence: true
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
     data
   else
     Material.all   # 全て表示する
   end
 end


  private
  def update_cache
    #id（食材）をもった中間テーブル（→メニュー）
    menu_materials = MenuMaterial.where( material_id: self.id )

    menu_materials.each do |menu_material|

      id = menu_material.menu_id
      aaa = MenuMaterial.where(menu_id: id)

      kingaku = 0
      aaa.each do |a|
        used = a.amount_used
        cost = a.material.cost_price
        price = used * cost
        kingaku = kingaku + price
      end

      menu = Menu.find(id)
      menu.update(cost_price: kingaku)
    end
  end
end
