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
          # if i == 0
          #   font "vendor/assets/fonts/ipaexg.ttf"
          # elsif i == 1
          #   font "vendor/assets/fonts/ZenMaruGothic-Medium.ttf"
          # elsif i == 2
          #   font "vendor/assets/fonts/ipaexm.ttf"
          # elsif i == 3
          #   font "vendor/assets/fonts/ZenKakuGothicNew-Medium.ttf"
          # end
          font "vendor/assets/fonts/ipaexm.ttf"
          # fill_color 'ffffff'
          image open(product.image.url), at: [10, h], width:184
          fill_color '000000'
          line_width 0.1
          stroke_color 'ececec'
          stroke_rectangle [10,h], 510, 184
          fill_color '000000'
          text_box(product.food_label_name,at: [215,h-18], width: 220, height: 50,size:18,valign: :center, leading: 3)
          line_width 1
          line [210, h-75], [500, h-75]
          stroke_color '000000'
          stroke

          text_box(product.contents,at: [215,h-80], width: 280, height: 20,size:8,valign: :center)


          fill_color '000000'
          text_box("<font size='30'>#{product.sell_price}</font>円",at: [355, h - 135], width: 100, height: 40,size:16,inline_format: true)
          text_box("1人前",at: [440, h - 138], width: 100, height: 40,size:11)
          text_box("（税込 #{product.tax_including_sell_price} 円）",at: [430, h - 153], width: 100, height: 40,size:10)

          font "vendor/assets/fonts/ipaexg.ttf"
          if product.product_category == "スイーツ・ドリンク"
            fill_color 'F2684A'
            fill_rounded_rectangle [215,h-130], 36, 36, 18
            fill_color 'ffffff'
            text_box("甘味",at: [217, h - 143], width: 36, height: 36, rotate_around: :center,align: :center,size:10)
          else
            fill_color '78B86D'
            fill_rounded_rectangle [215,h-130], 36, 36, 18
            fill_color 'ffffff'
            text_box("週替り",at: [216, h - 143], width: 36, height: 36, rotate_around: :center,align: :center,size:9)
          end

          if product.warm_flag == true
            fill_color 'ce5242'
            fill_rounded_rectangle [260,h-130], 36, 36, 18
            fill_color 'ffffff'
            text_box("温め",at: [261, h - 143], width: 36, height: 36, rotate_around: :center,align: :center,size:11)
          end
        end
      else
        stroke do
          font "vendor/assets/fonts/ipaexm.ttf"
          # fill_color 'ffffff'
          fill_color '000000'
          line_width 0.1
          stroke_color 'ececec'
          stroke_rectangle [10,h], 510, 184
          fill_color '000000'
          text_box(product.food_label_name,at: [80,h-16], width: 420, height: 50,size:22,valign: :center, leading: 3)


          line_width 1
          line [30, h-75], [500, h-75]
          stroke_color '000000'
          stroke

          text_box(product.contents,at: [30,h-80], width: 450, height: 20,size:10,valign: :center)


          fill_color '000000'
          text_box("<font size='40'>#{product.sell_price}</font>円",at: [325, h - 128], width: 100, height: 40,size:16,inline_format: true)
          text_box("1人前",at: [425, h - 135], width: 100, height: 40,size:14)
          text_box("（税込 #{product.tax_including_sell_price} 円）",at: [420, h - 153], width: 100, height: 40,size:11)

          font "vendor/assets/fonts/ipaexg.ttf"
          if product.product_category == "スイーツ・ドリンク"
            fill_color 'F2684A'
            fill_rounded_rectangle [30,h-110], 54, 54, 27
            fill_color 'ffffff'
            text_box("甘味",at: [31, h - 130], width: 54, height: 54, rotate_around: :center,align: :center,size:14)
          else
            fill_color '3548AF'
            fill_rounded_rectangle [30,h-110], 54, 54, 27
            fill_color 'ffffff'
            text_box("週替り",at: [31, h - 130], width: 54, height: 54, rotate_around: :center,align: :center,size:14)
          end

          if product.warm_flag == true
            fill_color 'cc0000'
            fill_rounded_rectangle [95,h-110], 54, 54, 27
            fill_color 'ffffff'
            text_box("温め",at: [96, h - 128], width: 54, height: 40, rotate_around: :center,align: :center,size:17)

          end
        end
      end
      h -= 184
    end
  end
end
