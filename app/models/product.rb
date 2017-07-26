class Product < ActiveRecord::Base
  has_one :recipe
  has_many :materials


  def self.search(params) #self.でクラスメソッドとしている
   if params # 入力がある場合の処理
     data = Product.all
     data = data.where(['product_name LIKE ?', "%#{params["product_name"]}%"]) if params["product_name"]
     data = data.where(['cook_category LIKE ?', "%#{params["cook_category"]}%"]) if params["cook_category"]
     data = data.where(['product_type LIKE ?', "%#{params["product_type"]}%"]) if params["product_type"]
     data
   else
     Product.all   # 全て表示する
   end
 end
end
