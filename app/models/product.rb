class Product < ApplicationRecord
  has_many :pre_order_products
  has_many :product_sales_potentials
  has_many :analysis_products
  belongs_to :group
  belongs_to :brand
  belongs_to :container

  has_many :product_bbs, dependent: :destroy
  accepts_nested_attributes_for :product_bbs, allow_destroy: true

  has_many :product_menus,->{order("product_menus.row_order asc") }, dependent: :destroy
  has_many :menus, through: :product_menus
  accepts_nested_attributes_for :product_menus, allow_destroy: true

  has_many :daily_menus, through: :daily_menu_details
  has_many :daily_menu_details

  has_many :store_daily_menus, through: :store_daily_menu_details
  has_many :store_daily_menu_details

  has_many :order_products, dependent: :destroy
  has_many :orders, through: :order_products

  has_many :product_parts, dependent: :destroy
  accepts_nested_attributes_for :product_parts, allow_destroy: true

  has_many :product_ozara_serving_informations, dependent: :destroy
  accepts_nested_attributes_for :product_ozara_serving_informations, allow_destroy: true

  has_many :product_pack_serving_informations, dependent: :destroy
  accepts_nested_attributes_for :product_pack_serving_informations, allow_destroy: true


  has_many :tastings
  
  mount_uploader :image, ProductImageUploader
  mount_uploader :display_image, ProductImageUploader
  mount_uploader :image_for_one_person, ProductImageUploader

  validates :name, presence: true, uniqueness: true, format: { with: /\A[^０-９ａ-ｚＡ-Ｚ]+\z/,message: "：全角英数字は使用出来ません。"}
  validates :sell_price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :cost_price, presence: true, numericality: true
  enum sub_category: {グランドメニュー:1,週替わりメニュー:2,"1月":3,"2月":4,"3月":5,"4月":6,"5月":7,"6月":8,"7月":9,"8月":10,"9月":11,"10月":12,"11月":13,"12月":14,イベント:15}
  enum product_category: {主菜:1,ご飯・丼:2,スイーツ:3,備品:4,お弁当:5,オードブル:6,スープ:7,惣菜（仕入れ）:8,レジ修正:9,オプション:11,その他:12,冷菜:13,温菜:14,揚げ物:15,焼き物:16,ご飯物:17,デザート:18,カレー:19,副菜:20,サラダ:21,スープ大:22}
  enum status: {販売中:1,販売停止:2,試作中:3,製造用:4}
  before_save :name_code
  before_destroy :clean_s3

  def self.search(params,group_id)
    data = Product.where(group_id:group_id).order(id: "DESC").all
    if params
      data = data.where(brand_id: params["brand_id"]) if params["brand_id"].present?
      data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
      data = data.where(product_category: params["product_category"]) if params["product_category"].present?
      data = data.where(sub_category: params["sub_category"]) if params["sub_category"].present?
      data = data.reorder(params['order']) if params["order"].present?
      data
    end
  end


  def self.allergy_seiri(product)
    arr=[]
    product.menus.includes([:materials]).each do |prme|
      prme.materials.each do |mate|
        arr << mate.allergy
      end
    end
    @arr = arr.flatten.uniq
    @arr.delete("")
    @arr.delete("0")
    @arr.delete(0)
    allergy = {"egg"=>"卵","milk"=>"乳","shrimp"=>"えび","crab"=>"かに","peanuts"=>"落花生","soba"=>"そば","wheat"=>"小麦"}
    @arr = @arr.map{|ar| allergy[ar]}
  end
  def self.additive_seiri(product)
    arr=[]
    product.menus.each do |prme|
      arr << prme.used_additives
    end
    @brr = arr.flatten.uniq
    @brr.delete("")
    @brr.delete("0")
    @brr.delete(0)
    @brr = @brr.map{|br| FoodAdditive.find(br).name}
  end

  private
    def name_code
      #波ダッシュなどの置換
      mappings = {
        "\u{00A2}" => "\u{FFE0}",
        "\u{00A3}" => "\u{FFE1}",
        "\u{00AC}" => "\u{FFE2}",
        "\u{2016}" => "\u{2225}",
        "\u{2012}" => "\u{FF0D}",
        "\u{301C}" => "\u{FF5E}"
      }
      mappings.each{|before, after| self.name = self.name.gsub(before, after) }
      self.name = self.name.encode(Encoding::Windows_31J, undef: :replace).encode(Encoding::UTF_8)
    end

    def clean_s3
      image.remove!       #オリジナルの画像を削除
      image.thumb.remove! #thumb画像を削除
    rescue Excon::Errors::Error => error
      puts "Something gone wrong"
      false
    end

end
