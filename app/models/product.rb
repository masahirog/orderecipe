class Product < ApplicationRecord
  # has_one :recipe
  has_many :product_menus, dependent: :destroy
  has_many :menus, through: :product_menus
  accepts_nested_attributes_for :product_menus, allow_destroy: true

  mount_uploader :product_image, ProductImageUploader

  validates :name, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true, format: { with: /\A[\A[0-9a-zA-Zぁ-んァ-ンー-龥:\(\)＆・]+\z]+\z/,
    message: "：全角 [かな、カナ、漢字、＆、・]　　半角 [英数字、括弧] が使用可能です"}
  validates :cook_category, presence: true
  validates :product_type, presence: true
  validates :sell_price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :cost_price, presence: true, numericality: true
  validates :description, presence: true, format: { with: /\A[^”’（）｜‘＿＾；　０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字スペース及び、全角記号^”’（）｜‘＿＾；は使用出来ません。"}
  validates :contents, presence: true, format: { with: /\A[^”’（）｜‘＿＾；　０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字スペース及び、全角記号^”’（）｜‘＿＾；は使用出来ません。"}

  def self.search(params) #self.でクラスメソッドとしている
   if params
     data = Product.all
     data = data.where(cook_category: params["cook_category"]) if params["cook_category"].present?
     data = data.where(product_type: params["product_type"]) if params["product_type"].present?
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data
   else
     data = Product.all
   end
  end
end
