class StorePriceCard < Prawn::Document
  def initialize(store_daily_menu_ids)
    super(
      page_size: 'A4',
      :top_margin    => 0 )
    #日本語のフォント
    StoreDailyMenu.where(id:store_daily_menu_ids).each_with_index do |sdm,n|
      card(sdm,n)
    end
  end


  def card(store_daily_menu,n)
    font "vendor/assets/fonts/NotoSansJP-Black.ttf"
    product_ids = store_daily_menu.store_daily_menu_details.where(pricecard_need_flag:true).map{|sdmd|sdmd.product_id}
    products = []
    # daily_menu_detailsを優先する
    store_daily_menu.daily_menu.daily_menu_details.where(product_id:product_ids).each do |dmd|
      product = dmd.product
      product.sell_price = dmd.sell_price
      product.tax_including_sell_price = (dmd.sell_price * 1.08).floor
      products << product
    end
    start_new_page if n > 0 && products.present?
    i = 0
    products.each_slice(4) do |products_data|
      h =750
      start_new_page if i > 0
      i += 1
      fill_color "000000"
      text_box "#{store_daily_menu.store.short_name}", at: [0, 770], :size =>8 
      products_data.each do |product|
        if product.image.present?
          stroke do
            font "vendor/assets/fonts/NotoSansJP-Black.ttf"
            # fill_color 'ffffff'
            image URI.open(product.image.url), at: [10, h], width:184
            fill_color '000000'
            line_width 0.1
            stroke_color '808080'
            stroke_rectangle [10,h], 510, 184
            fill_color '000000'

            if product.food_label_name.length < 15
              text_box(product.food_label_name,at: [210,h-5], width: 290, height: 50,size:20,valign: :bottom, leading: 3,align: :center)
            elsif product.food_label_name.length < 17
              text_box(product.food_label_name,at: [210,h-5], width: 290, height: 50,size:18,valign: :bottom, leading: 3,align: :center)
            else
              text_box(product.food_label_name,at: [210,h-5], width: 290, height: 50,size:17,valign: :bottom, leading: 4,align: :center)
            end


            line_width 2
            line [210, h-65], [500, h-65]
            stroke_color '000000'
            stroke
            fill_color '000000'
            x = 210
            text_box("<font size='25'>#{product.sell_price}</font> 円",at: [x+150, h - 112], width: 100, height: 40,size:15,inline_format: true)
            font "vendor/assets/fonts/NotoSansJP-Medium.ttf"
            text_box(product.sales_unit,at: [x+100, h - 120], width: 100, height: 40,size:13)
            text_box("（税込 #{product.tax_including_sell_price} 円）",at: [x+210, h - 125], width: 100, height: 40,size:11)
            text_box(product.contents,at: [215,h-75], width: 280, height: 30,size:11,valign: :top,align: :center, leading: 3)

            font "vendor/assets/fonts/NotoSansJP-Black.ttf"
            bounding_box([210, h - 150], :width => 290) do
              font "vendor/assets/fonts/NotoSansJP-Medium.ttf"
              data = [ ["カロリー", "たんぱく質", "脂質","炭水化物","食物繊維","糖質","塩分"],
                 ["#{product.calorie.floor}kcal", "#{product.protein.floor(1)}g", "#{product.lipid.floor(1)}g","#{product.carbohydrate.floor(1)}g", "#{product.dietary_fiber.floor(1)}g",
                  "#{(product.carbohydrate-product.dietary_fiber).floor(1)}g", "#{product.salt.floor(1)}g"] ]
              table(data) do
                cells.size = 8
                cells.text_color = "333333"
                cells.border_width = 0.4
                cells.border_color = "c0c0c0"
                cells.borders = []
                row(0).borders = [:bottom]
                cells.padding = [3,2,3,2]
                cells.align = :center
                self.column_widths = [50,50,40,40,40,35,35]
              end
            end
            if product.warm_flag == true
              fill_color 'ce5242'
              fill_rounded_rectangle [260,h-110], 30, 30, 15
              fill_color 'ffffff'
              text_box("温め",at: [258, h - 120], width: 36, height: 36, rotate_around: :center,align: :center,size:10)
            end

          end
        else
          stroke do
            font "vendor/assets/fonts/NotoSansJP-Black.ttf"
            fill_color '000000'
            line_width 0.1
            stroke_color '808080'
            stroke_rectangle [10,h], 510, 184
            if product.food_label_name.length < 15
              text_box(product.food_label_name,at: [40,h-20], width: 450, height: 50,size:30,valign: :bottom, leading: 5,align: :center)
            elsif product.food_label_name.length < 17
              text_box(product.food_label_name,at: [40,h-20], width: 450, height: 50,size:27,valign: :bottom, leading: 5,align: :center)
            elsif product.food_label_name.length < 19
              text_box(product.food_label_name,at: [40,h-20], width: 450, height: 50,size:25,valign: :bottom, leading: 5,align: :center)
            else
              text_box(product.food_label_name,at: [65,h-20], width: 400, height: 50,size:22,valign: :bottom, leading: 5,align: :center)
            end

            line_width 2
            line [30, h-80], [500, h-80]
            stroke_color '000000'
            stroke

            fill_color '000000'


            x = 210
            text_box("<font size='25'>#{product.sell_price}</font> 円",at: [x+150, h - 112], width: 100, height: 40,size:15,inline_format: true)
            font "vendor/assets/fonts/NotoSansJP-Medium.ttf"
            text_box(product.sales_unit,at: [x+100, h - 120], width: 100, height: 40,size:13)
            text_box("（税込 #{product.tax_including_sell_price} 円）",at: [x+210, h - 125], width: 100, height: 40,size:11)
            text_box(product.contents,at: [35,h-90], width: 465, height: 30,size:11,valign: :top,align: :center, leading: 3)



            bounding_box([115, h - 150], :width => 290) do
              font "vendor/assets/fonts/NotoSansJP-Medium.ttf"
              data = [ ["カロリー", "たんぱく質", "脂質","炭水化物","食物繊維","糖質","塩分"],
                 ["#{product.calorie.floor}kcal", "#{product.protein.floor(1)}g", "#{product.lipid.floor(1)}g","#{product.carbohydrate.floor(1)}g", "#{product.dietary_fiber.floor(1)}g",
                  "#{(product.carbohydrate-product.dietary_fiber).floor(1)}g", "#{product.salt.floor(1)}g"] ]
              table(data) do
                cells.size = 8
                cells.text_color = "333333"
                cells.border_width = 0.4
                cells.border_color = "c0c0c0"
                cells.borders = []
                row(0).borders = [:bottom]
                cells.padding = [3,2,3,2]
                cells.align = :center
                self.column_widths = [50,50,40,40,40,35,35]
              end
            end

            if product.warm_flag == true
              fill_color 'ce5242'
              fill_rounded_rectangle [260,h-110], 30, 30, 15
              fill_color 'ffffff'
              text_box("温め",at: [258, h - 120], width: 36, height: 36, rotate_around: :center,align: :center,size:10)
            end
          end
        end
        h -= 184
      end
    end
  end
end
