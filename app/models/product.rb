class Product < ApplicationRecord
  has_many :product_sales_potentials
  has_many :analysis_products
  belongs_to :group
  belongs_to :brand
  belongs_to :container

  has_many :product_pops, dependent: :destroy
  accepts_nested_attributes_for :product_pops, allow_destroy: true

  has_many :product_menus,->{order("product_menus.row_order asc") }, dependent: :destroy
  has_many :menus, through: :product_menus
  accepts_nested_attributes_for :product_menus, allow_destroy: true

  has_many :daily_menus, through: :daily_menu_details
  has_many :daily_menu_details

  has_many :store_daily_menus, through: :store_daily_menu_details
  has_many :store_daily_menu_details

  has_many :kurumesi_orders, through: :kurumesi_order_details
  has_many :kurumesi_order_details


  has_many :order_products, dependent: :destroy
  has_many :orders, through: :order_products

  belongs_to :cooking_rice

  has_many :product_parts, dependent: :destroy
  accepts_nested_attributes_for :product_parts, allow_destroy: true

  has_many :product_ozara_serving_informations, dependent: :destroy
  accepts_nested_attributes_for :product_ozara_serving_informations, allow_destroy: true

  has_many :tastings
  
  mount_uploader :image, ProductImageUploader
  mount_uploader :display_image, ProductImageUploader
  mount_uploader :image_for_one_person, ProductImageUploader
  mount_uploader :sky_image, ProductImageUploader

  validates :name, presence: true, uniqueness: true, format: { with: /\A[^０-９ａ-ｚＡ-Ｚ]+\z/,message: "：全角英数字は使用出来ません。"}
  validates :sell_price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :cost_price, presence: true, numericality: true
  validates :management_id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, :allow_nil => true
  enum product_category: {惣菜:1,ご飯・丼:2,ドリンク:3,備品:4,お弁当:5,オードブル:6,スープ:7,惣菜（仕入れ）:8,レジ修正:9,オプション:11,その他:12}
  enum status: {販売中:1,販売停止:2,試作中:3}
  before_save :name_code
  before_destroy :clean_s3

  def view_name_and_id
    self.management_id.to_s + '｜' + self.name
  end

  def self.search(params,group_id)
    data = Product.where(group_id:group_id).order(id: "DESC").all
    if params
      data = data.where(['management_id LIKE ?', "%#{params["management_id"]}%"]) if params["management_id"].present?
      data = data.where(brand_id: params["brand_id"]) if params["brand_id"].present?
      data = data.where(['name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
      data = data.reorder(params['order']) if params["order"].present?
      data
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
      arr << prme.used_additives
    end
    @brr = arr.flatten.uniq
    @brr.delete("")
    @brr.delete("0")
    @brr.delete(0)
    @brr = @brr.map{|br| FoodAdditive.find(br).name}
  end

  # def self.make_katakana(kanji)
  #   result = ''
  #   app_id = "6e84997fe5d4d3865152e765091fd0faab2f76bfe5dba29d638cc6683efa1184"
  #   header = {'Content-type'=>'application/json'}
  #   https = Net::HTTP.new('labs.goo.ne.jp', 443)
  #   https.use_ssl = true
  #   sentence = kanji.gsub(/\r\n/, '|||').gsub(/\n/, '|||')
  #   request_data = {'app_id'=>app_id, "sentence"=>sentence}.to_json
  #   while result.blank? do
  #     sleep(0.1)
  #     response = https.post('/api/morph', request_data, header)
  #     if JSON.parse(response.body)["word_list"].present?
  #       result = JSON.parse(response.body)["word_list"]
  #     end
  #   end
  #   @katakana = ''
  #   if result.present?
  #     result.flatten.in_groups_of(3).each do |ar|
  #       if ar[1] == '句点'
  #         @katakana += "。"
  #       elsif ar[1] == '読点'
  #         @katakana += "、"
  #       elsif ar[1] == 'Number' || ar[0] == '-' || ar[1] == '括弧'|| ar[1] == "Alphabet" || ar[1] == "Symbol"
  #         @katakana += ar[0]
  #       elsif ar[1] == '空白'
  #         @katakana += "　"
  #       else
  #         @katakana += ar[2]
  #       end
  #     end
  #     @katakana = @katakana.gsub('|||',"\n").split("^^", -1)
  #   end
  # end

  def self.input_spreadsheet
    session = GoogleDrive::Session.from_config("config.json")
    sheet = session.spreadsheet_by_key("1hZ00gO4ur_jvwzuj6BHMqJXLq3J1zJTchoGH19lLVt0").worksheet_by_title("原価OR連携")
    last_row = sheet.num_rows
    for i in 2..last_row do
      id = sheet[i, 1]
      if id.present?
        product = Product.find_by_id(id)
        if product.present?
          sheet[i, 2] = product.cost_price
          if product.serving_infomation.present?
            sheet[i, 3] = product.serving_infomation.gsub("\b","")
          else
            sheet[i, 3] = ""
          end
          if product.main_serving_plate_id.present?
            sheet[i, 4] = ServingPlate.find(product.main_serving_plate_id).name
          else
            sheet[i, 4] = ""
          end
          if product.container_id.present?
            sheet[i, 5] = product.container.name
          else
            sheet[i, 5] = ""
          end

        end
      end
    end
    sheet.save
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
