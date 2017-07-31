class Menu < ApplicationRecord
  has_many :menu_materials, dependent: :destroy
  has_many :materials, through: :menu_materials
  accepts_nested_attributes_for :menu_materials, allow_destroy: true


  def self.search(params) #self.でクラスメソッドとしている
   if params # 入力がある場合の処理
     data = Menu.all
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data
   else
     Menu.all   # 全て表示する
   end
  end

end
