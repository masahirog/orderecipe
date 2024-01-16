class PriceCard < Prawn::Document
  def initialize(products)
    super(
      page_size: 'A4',
      :top_margin    => 0 )
    #日本語のフォント
    card(products)
  end


  def card(products)
    h =750
    products.each_with_index do |product,i|
      if product.image.present?
        stroke do
          font "vendor/assets/fonts/NotoSansJP-Black.ttf"
          # fill_color 'ffffff'
          image open(product.image.url), at: [10, h], width:184
          fill_color '000000'
          line_width 0.1
          stroke_color 'ececec'
          stroke_rectangle [10,h], 510, 184
          fill_color '000000'

          if product.food_label_name.length < 15
            text_box(product.food_label_name,at: [210,h-15], width: 290, height: 50,size:20,valign: :bottom, leading: 3,align: :center)
          elsif product.food_label_name.length < 17
            text_box(product.food_label_name,at: [210,h-15], width: 290, height: 50,size:18,valign: :bottom, leading: 3,align: :center)
          else
            text_box(product.food_label_name,at: [210,h-15], width: 290, height: 50,size:17,valign: :bottom, leading: 4,align: :center)
          end


          line_width 2
          line [210, h-75], [500, h-75]
          stroke_color '000000'
          stroke

          fill_color '000000'
          text_box("<font size='25'>#{product.sell_price}</font> 円",at: [325, h - 127], width: 100, height: 40,size:15,inline_format: true)

          # text_box('〇〇〇〇〇',at: [194,h-130], width: 326, height: 50,size:15,valign: :center, leading: 3,align: :center)

          font "vendor/assets/fonts/NotoSansJP-Medium.ttf"
          text_box(product.contents,at: [215,h-85], width: 280, height: 30,size:11,valign: :top,align: :center, leading: 3)
          text_box("一人前",at: [280, h - 137], width: 100, height: 40,size:13)
          text_box("（税込 #{product.tax_including_sell_price} 円）",at: [305, h - 155], width: 100, height: 40,size:11)
          font "vendor/assets/fonts/NotoSansJP-Black.ttf"
          if product.product_category == "スイーツ・ドリンク"
            fill_color 'F2684A'
            fill_rounded_rectangle [420,h-128], 36, 36, 18
            fill_color 'ffffff'
            text_box("甘味",at: [420, h - 141], width: 36, height: 36, rotate_around: :center,align: :center,size:11)
          else
            fill_color '78B86D'
            fill_rounded_rectangle [420,h-128], 36, 36, 18
            fill_color 'ffffff'
            text_box("週替",at: [420, h - 141], width: 36, height: 36, rotate_around: :center,align: :center,size:11)
          end

          if product.warm_flag == true
            fill_color 'ce5242'
            fill_rounded_rectangle [465,h-128], 36, 36, 18
            fill_color 'ffffff'
            text_box("温め",at: [465, h - 141], width: 36, height: 36, rotate_around: :center,align: :center,size:11)
          end
        end
      else
        stroke do
          font "vendor/assets/fonts/NotoSansJP-Black.ttf"
          fill_color '000000'
          line_width 0.1
          stroke_color 'ececec'
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
          text_box("<font size='30'>#{product.sell_price}</font> 円",at: [255, h - 123], width: 100, height: 40,size:15,inline_format: true)

          font "vendor/assets/fonts/NotoSansJP-Medium.ttf"          
          text_box(product.contents,at: [35,h-90], width: 465, height: 30,size:11,valign: :top,align: :center, leading: 3)
          text_box("一人前",at: [210, h - 138], width: 100, height: 40,size:12)
          text_box("（税込 #{product.tax_including_sell_price} 円）",at: [224, h - 155], width: 100, height: 40,size:13)
          font "vendor/assets/fonts/NotoSansJP-Black.ttf"
          if product.product_category == "スイーツ・ドリンク"
            fill_color 'F2684A'
            fill_rounded_rectangle [360,h-130], 36, 36, 18
            fill_color 'ffffff'
            text_box("甘味",at: [360, h - 142], width: 36, height: 36, rotate_around: :center,align: :center,size:12)
          else
            fill_color '78B86D'
            fill_rounded_rectangle [360,h-130], 36, 36, 18
            fill_color 'ffffff'
            text_box("週替",at: [360, h - 142], width: 36, height: 36, rotate_around: :center,align: :center,size:12)
          end

          if product.warm_flag == true
            fill_color 'ce5242'
            fill_rounded_rectangle [405,h-130], 36, 36, 18
            fill_color 'ffffff'
            text_box("温め",at: [405, h - 142], width: 36, height: 36, rotate_around: :center,align: :center,size:12)
          end
        end
      end
      h -= 184
    end
  end
end
