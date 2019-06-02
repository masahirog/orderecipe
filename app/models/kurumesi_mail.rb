class KurumesiMail < ApplicationRecord
  def self.input_order(body)
    arr = []
    order_details_arr = []
    body.gsub(" ", "").gsub("　","").each_line{|string| arr << string.strip}
    arr = arr.compact.reject(&:empty?)
    order_info_index = arr.index("┏▼ご注文情報━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
    shohin_index = arr.index("┏▼ご注文商品━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
    info_arr = arr[order_info_index..shohin_index-1]
    shohin_arr = arr[shohin_index+1..-1]
    order = {}

    info_arr.each do |line|
      order[:delivery_date] = line[6..15] if line[0..5] == "[配達日時]"
      order[:kurumesi_order_id] = line[6..-1].to_i if line[0..5] == "[注文番号]"
      if line[0..5]== "[支払方法]"
        if line[6..7] == '請求'
          order[:pay] = 0
        else
          order[:pay] = 1
        end
      end
    end
    order[:miso] = 0
    order[:tea] = 0
    order[:trash_bags] = 0
    shohin_arr.join('').gsub('【','$$$').gsub('[請求金額]','$$$').split("$$$").reject(&:blank?).each do |line|
      product_name = ""
      num = ""

      #ごみ袋
      order[:trash_bags] = line.match(/×(.+)食/)[1].to_i if line.include?("ゴミ袋")

      # 茶の有無
      if line.include?('ペット茶')
        order[:tea] = 1
      elsif line.include?('缶茶')
        order[:tea] = 2
      end
      # 味噌有無
      order[:miso] = 1 if line.include?('味噌汁付き')
      if line.index('】').present?
        product_name_end_kakko = line.index('】') - 1
        product_name = line[0..product_name_end_kakko]

        # product_id = Product.find_by(name:product_name).id
        product = Product.where("name LIKE ?", "%#{product_name}%").first
        if product.present?
          product_id = product.id
          num = line.match(/×(.+)食/)[1].to_i if line.match(/×(.+)食/).present?
          order_details_arr << {product_id:product_id,num:num}
        end
      end
    end
    order[:order_details] = order_details_arr
    order
  end
end
