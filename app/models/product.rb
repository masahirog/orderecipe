class Product < ApplicationRecord
  has_one :recipe
  has_many :materials


  def self.search(params) #self.でクラスメソッドとしている
   if params
     data = Product.all
     data = data.where(['cook_category LIKE ?', "%#{params["cook_category"]}%"]) if params["cook_category"].present?
     data = data.where(['product_type LIKE ?', "%#{params["product_type"]}%"]) if params["product_type"].present?
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data
   else
     data = Product.all
  end
 end
end
