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

  private
  def update_product_cost_price
    #id（食材）をもった中間テーブル（→メニュー）
    product_menus = ProductMenu.where( menu_id: self.id )

    product_menus.each do |product_menu|

      id = product_menu.product_id
      aaa = ProductMenu.where(product_id: id)

      kingaku = 0
      aaa.each do |a|
        cost = a.menu.cost_price
        kingaku = kingaku + cost
      end

      product = Product.find(id)
      product.update(cost_price: kingaku)
    end
  end
end
