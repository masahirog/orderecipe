class Material < ApplicationRecord
  has_many :menu_materials, dependent: :destroy
  has_many :menus, through: :menu_materials

  def self.search(params) #self.でクラスメソッドとしている
   if params # 入力がある場合の処理
     data = Material.all
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data = data.where(['delivery_slip_name LIKE ?', "%#{params["delivery_slip_name"]}%"]) if params["delivery_slip_name"].present?
     data = data.where(['vendor LIKE ?', "%#{params["vendor"]}%"]) if params["vendor"].present?
     data = data.where(['code LIKE ?', "%#{params["code"]}%"]) if params["code"].present?
     data
   else
     Material.all   # 全て表示する
   end
 end
end
