class Product < ApplicationRecord
  belongs_to :brand

  has_many :product_menus,->{order("product_menus.row_order asc") }, dependent: :destroy
  has_many :menus, through: :product_menus
  accepts_nested_attributes_for :product_menus, allow_destroy: true

  has_many :daily_menus, through: :daily_menu_details
  has_many :daily_menu_details

  has_many :masu_orders, through: :masu_order_details
  has_many :masu_order_details


  has_many :order_products, dependent: :destroy
  has_many :orders, through: :order_products

  mount_uploader :image, ProductImageUploader

  validates :name, presence: true, uniqueness: true, format: { with: /\A[^０-９ａ-ｚＡ-Ｚ]+\z/,
    message: "：全角英数字は使用出来ません。"}
  validates :cook_category, presence: true
  validates :product_type, presence: true
  validates :sell_price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :cost_price, presence: true, numericality: true
  validates :management_id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, :uniqueness => true, :allow_nil => true

  enum product_type: {ノーマル:1,デラックス:2,ヘルシー:3,ボウル:4,新ヘルシー:5,W弁:6,プレミアム:7}
  enum cook_category: {その他:1,グリル:2,コンロ:3,フライヤー:4,グリルコンロ:5,スチコン:6,前日コンロ:7,グリルコンロ:8,前日グリル:9,フライヤー・コンロ:10,フライヤー・グリル:11}
  enum product_category: {弁当:1,他:2}
  def view_name_and_id
    self.management_id.to_s + '｜' + self.name
  end

  def self.search(params)
   if params
     data = Product.order(id: "DESC").all
     data = data.where(['management_id LIKE ?', "%#{params["management_id"]}%"]) if params["management_id"].present?
     data = data.where(cook_category: params["cook_category"]) if params["cook_category"].present?
     data = data.where(product_type: params["product_type"]) if params["product_type"].present?
     data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
     data = data.reorder(params['order']) if params["order"].present?
     data
   else
     data = Product.order(id: "DESC").all
   end
  end

  def self.bentoid
    max = Product.maximum(:management_id)
    if max.nil?
      data = 1
    else
      data = max + 1
    end
  end

  def self.allergy_seiri(product)
    arr=[]
    product.menus.each do |prme|
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
      binding.pry
      arr << prme.used_additives
    end
    @brr = arr.flatten.uniq
    @brr.delete("")
    @brr.delete("0")
    @brr.delete(0)
    @brr = @brr.map{|br| FoodAdditive.find(br).name}
  end


  def self.make_katakana(kanji)
    result = ''
    app_id = "6e84997fe5d4d3865152e765091fd0faab2f76bfe5dba29d638cc6683efa1184"
    header = {'Content-type'=>'application/json'}
    https = Net::HTTP.new('labs.goo.ne.jp', 443)
    https.use_ssl = true
    request_data = {'app_id'=>app_id, "sentence"=>kanji}.to_json
    while result.blank? do
      sleep(0.1)
      response = https.post('/api/morph', request_data, header)
      if JSON.parse(response.body)["word_list"].present?
        result = JSON.parse(response.body)["word_list"]
      end
    end
    @katakana = ''
    if result.present?
      result.flatten.in_groups_of(3).each do |ar|
        if ar[2] == "＄"
          if ar[1] == '句点'
            @katakana += "。"
          elsif ar[1] == '読点'
            @katakana += "、"
          elsif ar[1] == 'Number' || ar[0] == '-' || ar[1] == '括弧'
            @katakana += ar[0]
          elsif ar[1] == '空白'
            @katakana += "　"
          elsif ar[1] == "Symbol"
            @katakana += ar[0]
          end
        elsif ar[1] == "Alphabet" || ar[1] == "Number"
          @katakana += ar[0]
        else
          @katakana += ar[2]
        end
      end
      @katakana = @katakana.split("^^", -1)
    end
  end
end
