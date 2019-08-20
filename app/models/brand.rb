class Brand < ApplicationRecord
  has_many :products

  # 枡々
  def self.masu_order_make(order_details_arr,line,product_name,num)
    if line.index('】').present?
      product_name_end_kakko = line.index('】') - 1
      product_name = line[0..product_name_end_kakko]

      # product_id = Product.find_by(name:product_name).id
      product = Product.find_by(name:product_name)
      if product.present?
        product_id = product.id
        num = line.match(/×(.+)食/)[1].to_i
        order_details_arr << {product_id:product_id,num:num}
        # 味噌有無
        if line.include?('味噌汁付き')
          order_details_arr << {product_id:3831,num:num}
        end
        # 茶の有無
        if line.include?('ペット茶')
          order_details_arr << {product_id:3791,num:num}
        elsif line.include?('缶茶')
          order_details_arr << {product_id:3801,num:num}
        end
      end
    end
  end

  # HASI TO SAJI
  def self.hasisaji_order_make(order_details_arr,line,product_name,num)
    if line.index('】').present?
      base_product_name_end_kakko = line.index('】') - 1
      base_product_name = line[0..base_product_name_end_kakko]

      if line.index('[カレー]').present?
        curry_start = line.index('[カレー]') + 5
        curry_end = line.index('■') - 1
        option_curry = line[curry_start..curry_end]
      end
      product_name = base_product_name +"(" + option_curry + ")"
      # product_id = Product.find_by(name:product_name).id
      product = Product.find_by(name:product_name)
      if product.present?
        product_id = product.id
        num = line.match(/×(.+)食/)[1].to_i
        order_details_arr << {product_id:product_id,num:num}
        # 茶の有無
        if line.include?('ペット茶')
          order_details_arr << {product_id:3791,num:num}
        elsif line.include?('缶茶')
          order_details_arr << {product_id:3801,num:num}
        end
      end
    end
  end
end
