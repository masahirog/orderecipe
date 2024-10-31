require 'csv'
bom = "\uFEFF"
CSV.generate(bom) do |csv|
  hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
  csv_column_names = %w(商品名 原材料名 内容量 賞味期限 保存方法 販売者 販売単位 栄養成分 温め バーコード)
  csv << csv_column_names


  @allergies = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
  daily_menu_details = @daily_menu.daily_menu_details.includes(product:[:menus])
  @data = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
  @seibun = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }

  @daily_menu.daily_menu_details.where('mealselect_num > ?',0).each do |dmd|
    product = dmd.product
    allergy = Product.allergy_seiri(product)
    if product.product_category == "お弁当"
      @seibun[product.id] = {calorie:0,protein:0,lipid:0,carbohydrate:0,dietary_fiber:0,salt:0}
      product.product_menus.each do |pm|
        tpm = TemporaryProductMenu.find_by(daily_menu_detail_id:dmd.id,product_menu_id:pm.id)
        if tpm.present?
          menu = tpm.menu
        else
          menu = pm.menu
        end
        if menu.category == "容器"
        else
          @seibun[product.id][:calorie] += menu.calorie
          @seibun[product.id][:protein] += menu.protein
          @seibun[product.id][:lipid] += menu.lipid
          @seibun[product.id][:carbohydrate] += menu.carbohydrate
          @seibun[product.id][:dietary_fiber] += menu.dietary_fiber
          @seibun[product.id][:salt] += menu.salt

          if @data[product.id].present?
            @data[product.id] += "、【#{menu.food_label_name}】#{menu.food_label_contents}"
          else
            @data[product.id] = "【#{menu.food_label_name}】#{menu.food_label_contents}"
          end
        end
      end
      daily_menu_details.includes(product:[:menus]).where(paper_menu_number:[2,3]).each do |dmd|
        fukusai_product = dmd.product
        allergy += Product.allergy_seiri(fukusai_product)
        fukusai_product.product_menus.each do |pm|
          menu = pm.menu
          if menu.category == "容器"
          else
            @seibun[product.id][:calorie] += (menu.calorie * 0.3)
            @seibun[product.id][:protein] += (menu.protein * 0.3)
            @seibun[product.id][:lipid] += (menu.lipid * 0.3)
            @seibun[product.id][:carbohydrate] += (menu.carbohydrate * 0.3)
            @seibun[product.id][:dietary_fiber] += (menu.dietary_fiber * 0.3)
            @seibun[product.id][:salt] += (menu.salt * 0.3)

            if @data[product.id].present?
              @data[product.id] += "、【#{menu.food_label_name}】#{menu.food_label_contents}"
            else
              @data[product.id] = "【#{menu.food_label_name}】#{menu.food_label_contents}"
            end
          end
        end
      end
      fas = FoodAdditive.where(id:dmd.product.menus.map{|menu|menu.used_additives}.flatten.reject(&:blank?).uniq).map{|fa|fa.name}.join("、")
      if fas.present?
        @data[dmd.product_id] += "／#{fas}"
      else
      end
      allergy = allergy.uniq
      if allergy.present?
        @data[dmd.product_id] += "、(一部に#{allergy.join("、")}を含む)"
      else
      end

    else
      @data[product.id] = product.food_label_content
      @seibun[product.id][:calorie] = product.calorie
      @seibun[product.id][:protein] = product.protein
      @seibun[product.id][:lipid] = product.lipid
      @seibun[product.id][:carbohydrate] = product.carbohydrate
      @seibun[product.id][:dietary_fiber] = product.dietary_fiber
      @seibun[product.id][:salt] = product.salt
    end
  end
  @daily_menu.daily_menu_details.where('mealselect_num > ?',0).each do |dmd|
    shohinmei = dmd.product.food_label_name
    smaregi_code = dmd.product.smaregi_code
    genzairyo = @data[dmd.product_id]
    naiyoryo = dmd.product.sales_unit
    kigen = @daily_menu.start_time
    hozon = "要冷蔵（10℃以下）"
    hanbaisha = "株式会社結び 東京都中野区東中野1-35-1"
    hanbai_unit = "#{dmd.product.sales_unit}あたり"
    if dmd.product.warm_flag == true
      atatame = "蓋を外して、電子レンジ 500wで1分を目安に温めて、お召し上がり下さい。"
    else
      atatame = ""
    end
    seibun = "エネルギー #{@seibun[dmd.product_id][:calorie].round.to_s(:delimited)}kcal、たんぱく質 #{@seibun[dmd.product_id][:protein].round(1)}g、脂質 #{@seibun[dmd.product_id][:lipid].round(1)}g、炭水化物 #{@seibun[dmd.product_id][:carbohydrate].round(1)}g、糖質 #{(@seibun[dmd.product_id][:carbohydrate] - @seibun[dmd.product_id][:dietary_fiber]).round(1)}g、食物繊維 #{@seibun[dmd.product_id][:dietary_fiber].round(1)}g、塩分相当量 #{@seibun[dmd.product_id][:salt].round(1)}g"

    dmd.mealselect_num.times do
      csv << [shohinmei,genzairyo,naiyoryo,kigen,hozon,hanbaisha,hanbai_unit,seibun,atatame,smaregi_code]
    end
  end  

end
