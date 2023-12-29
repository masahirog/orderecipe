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
    products.each do |product|
      stroke do
        font "vendor/assets/fonts/ipaexm.ttf"
        # fill_color 'ffffff'
        fill_color '000000'
        line_width 0.1
        stroke_color 'ececec'
        stroke_rectangle [10,h], 510, 184
        fill_color '000000'
        text_box(product.food_label_name,at: [80,h-16], width: 300, height: 50,size:22,valign: :center)


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
        if product.product_category == "ドリンク"
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
      h -= 184
    end
  end
end
