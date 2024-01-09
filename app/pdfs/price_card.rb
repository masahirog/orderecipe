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
          text_box(product.food_label_name,at: [215,h-45], width: 280, height: 50,size:15,valign: :center, leading: 3,align: :center)
          line_width 2
          line [210, h-95], [500, h-95]
          stroke_color '000000'
          stroke

          fill_color '000000'
          text_box("<font size='22'>#{product.sell_price}</font> 円",at: [348, h - 135], width: 100, height: 40,size:12,inline_format: true)

          # text_box('〇〇〇〇〇',at: [194,h-130], width: 326, height: 50,size:15,valign: :center, leading: 3,align: :center)

          font "vendor/assets/fonts/NotoSansJP-Medium.ttf"
          text_box(product.contents,at: [215,h-100], width: 280, height: 20,size:8,valign: :center,align: :center, leading: 3)
          text_box("一人前",at: [312, h - 143], width: 100, height: 40,size:10)
          text_box("（税込 #{product.tax_including_sell_price} 円）",at: [325, h - 160], width: 100, height: 40,size:9)

          if product.product_category == "スイーツ・ドリンク"
            fill_color 'F2684A'
            fill_rounded_rectangle [460,h-10], 36, 36, 18
            fill_color 'ffffff'
            text_box("甘味",at: [461, h - 24], width: 36, height: 36, rotate_around: :center,align: :center,size:10)
          else
            fill_color '78B86D'
            fill_rounded_rectangle [460,h-10], 36, 36, 18
            fill_color 'ffffff'
            text_box("週替り",at: [461, h - 24], width: 36, height: 36, rotate_around: :center,align: :center,size:9)
          end

          if product.warm_flag == true
            fill_color 'ce5242'
            fill_rounded_rectangle [415,h-10], 36, 36, 18
            fill_color 'ffffff'
            text_box("温め",at: [416, h - 23], width: 36, height: 36, rotate_around: :center,align: :center,size:11)
          end
        end
      else
        stroke do
          font "vendor/assets/fonts/NotoSansJP-Black.ttf"
          fill_color '000000'
          line_width 0.1
          stroke_color 'ececec'
          stroke_rectangle [10,h], 510, 184
          fill_color '000000'
          text_box(product.food_label_name,at: [35,h-47], width: 465, height: 50,size:16,valign: :center, leading: 3,align: :center)
          line_width 2
          line [30, h-95], [500, h-95]
          # text_box('〇〇〇〇〇',at: [10,h-140], width: 510, height: 50,size:15,valign: :center, leading: 3,align: :center)
          stroke_color '000000'
          stroke

          fill_color '000000'
          text_box("<font size='22'>#{product.sell_price}</font> 円",at: [255, h - 135], width: 100, height: 40,size:12,inline_format: true)


          font "vendor/assets/fonts/NotoSansJP-Medium.ttf"
          text_box(product.contents,at: [35,h-100], width: 465, height: 20,size:9,valign: :center,align: :center, leading: 3)
          text_box("一人前",at: [219, h - 143], width: 100, height: 40,size:10)
          text_box("（税込 #{product.tax_including_sell_price} 円）",at: [232, h - 160], width: 100, height: 40,size:9)

          if product.product_category == "スイーツ・ドリンク"
            fill_color 'F2684A'
            fill_rounded_rectangle [460,h-10], 36, 36, 18
            fill_color 'ffffff'
            text_box("甘味",at: [461, h - 23], width: 36, height: 36, rotate_around: :center,align: :center,size:10)
          else
            fill_color '78B86D'
            fill_rounded_rectangle [460,h-10], 36, 36, 18
            fill_color 'ffffff'
            text_box("週替り",at: [461, h - 23], width: 36, height: 36, rotate_around: :center,align: :center,size:9)
          end

          if product.warm_flag == true
            fill_color 'ce5242'
            fill_rounded_rectangle [415,h-10], 36, 36, 18
            fill_color 'ffffff'
            text_box("温め",at: [416, h - 23], width: 36, height: 36, rotate_around: :center,align: :center,size:11)
          end
        end
      end
      h -= 184
    end
  end
end
