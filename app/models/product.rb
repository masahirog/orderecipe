class Product < ApplicationRecord
  has_many :product_menus, dependent: :destroy
  has_many :menus, through: :product_menus
  accepts_nested_attributes_for :product_menus, allow_destroy: true

  mount_uploader :product_image, ProductImageUploader

  validates :name, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true, format: { with: /\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  validates :cook_category, presence: true
  validates :product_type, presence: true
  validates :sell_price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :cost_price, presence: true, numericality: true

  def self.search(params)
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
