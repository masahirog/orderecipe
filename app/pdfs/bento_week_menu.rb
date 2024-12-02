require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'
require 'barby/barcode/qr_code'

class BentoWeekMenu < Prawn::Document
  def initialize(bento_menus,from,to)
    super(
      page_size: 'A4',
      page_layout: :landscape,
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/NotoSansJP-Medium.ttf"
    dates = bento_menus.keys.sort
    from = bento_menus.keys.first
    to = from + 7
    bento(bento_menus,dates,from,to)
  end


  def bento(bento_menus,dates,from,to)
    stroke do
      fill_color '000000'
      fill_rounded_rectangle [-5,525], 770, 80, 4
      fill_color 'ffffff'
      text_box("<font size='18'>#{from.month}</font>月<font size='18'>#{from.day}</font>日（#{%w(日 月 火 水 木 金 土)[from.wday]}）〜  <font size='18'>#{to.month}</font>月<font size='18'>#{to.day}</font>日（#{%w(日 月 火 水 木 金 土)[to.wday]}）",
       inline_format: true,color:'ffffff',at: [-5,515],align: :center, width: 770, height: 40)
      text_box("日替わり弁当のご案内",at: [-5,493], width: 770, height: 40,align: :center,size:20)
      text_box("主菜を１日２種類（お肉とお魚）、日替わりでご用意しております。",at: [-5,468], width: 770, height: 40,align: :center,size:9)
      fill_color 'cc0000'
      fill_rounded_rectangle [-20,540], 60, 60, 30
      fill_color 'ffffff'
      text_box("毎日\n替わる",at: [-7, cursor - 35], width: 40, height: 40,rotate: 20, rotate_around: :center,align: :center,size:13)
    end
    height = 430
    x = 0
    [from,from+1,from+4,from+5].each_with_index do |date,i|
      fill_color 'eeeeee'
      fill_rounded_rectangle [x,height], 380, 200, 2
      fill_color '000000'
      text_box(date.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[date.wday]})"),at: [x+10,height-15], width: 360, height: 30,size:20, valign: :center,align: :center)
      if bento_menus[date][24].present?
        text_box("① #{bento_menus[date][24].food_label_name}",at: [x+30,height-65], width: 350, height: 40,size:16)
      else
        text_box("定休日",at: [x+30,height-65], width: 350, height: 40,size:20,align: :center)
      end
      # text_box("#{bento_menus[date][24].sell_price}<font size='10'>円</font>",inline_format: true,at: [x+310,height-80], width: 350, height: 40,size:14)
      # text_box("税込 #{bento_menus[date][24].tax_including_sell_price}<font size='9'>円</font>",inline_format: true,at: [x+300,height-95], width: 350, height: 40,size:9)
      # text_box("690・790・890<font size='10'> 円</font>",inline_format: true,at: [x+240,height-90], width: 350, height: 40,size:14)
      # text_box("税込 745・853・961<font size='9'>円</font>",inline_format: true,at: [x+250,height-110], width: 350, height: 40,size:9)

      if bento_menus[date][25].present?
        text_box("② #{bento_menus[date][25].food_label_name}",at: [x+30,height-135], width: 350, height: 40,size:16)
      end
      # text_box("#{bento_menus[date][25].sell_price}<font size='10'>円</font>",inline_format: true,at: [x+310,height-150], width: 350, height: 40,size:14)
      # text_box("税込 #{bento_menus[date][25].tax_including_sell_price}<font size='9'>円</font>",inline_format: true,at: [x+300,height-165], width: 350, height: 40,size:9)
      # text_box("690・790・890<font size='10'> 円</font>",inline_format: true,at: [x+240,height-160], width: 350, height: 40,size:14)
      # text_box("税込 745・853・961<font size='9'>円</font>",inline_format: true,at: [x+250,height-180], width: 350, height: 40,size:9)

      if i == 1
        height = 430
        x = 400
      else
        height -= 220
      end
    end
    start_new_page

    height = 520
    x = 0
    [from+2,from+3,from+6,from+7].each_with_index do |date,i|
      fill_color 'eeeeee'
      fill_rounded_rectangle [x,height], 380, 200, 2
      fill_color '000000'
      text_box(date.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[date.wday]})"),at: [x+10,height-15], width: 360, height: 30,size:20, valign: :center,align: :center)
      if bento_menus[date][24].present?
        text_box("① #{bento_menus[date][24].food_label_name}",at: [x+30,height-65], width: 350, height: 40,size:16)
      else
        text_box("定休日",at: [x+30,height-65], width: 350, height: 40,size:20,align: :center)
      end
      # text_box("690・790・890<font size='10'> 円</font>",inline_format: true,at: [x+240,height-90], width: 350, height: 40,size:14)
      # text_box("税込 745・853・961<font size='9'>円</font>",inline_format: true,at: [x+250,height-110], width: 350, height: 40,size:9)

      if bento_menus[date][25].present?
        text_box("② #{bento_menus[date][25].food_label_name}",at: [x+30,height-135], width: 350, height: 40,size:16)
      end
      # text_box("690・790・890<font size='10'> 円</font>",inline_format: true,at: [x+240,height-160], width: 350, height: 40,size:14)
      # text_box("税込 745・853・961<font size='9'>円</font>",inline_format: true,at: [x+250,height-180], width: 350, height: 40,size:9)

      if i == 1
        height = 520
        x = 400
      else
        height -= 220
      end
    end

    # self.line_width = 2
    # line [0, 70], [780, 70]
    # stroke_color 'eeeeee'
    # stroke
    text_box("お野菜たっぷり！すべてのおかずを手作りで毎日ご用意しています。",at: [0,80], width: 760, height: 40,size:18)
    text_box("野菜にお肉にお魚に、バランス良く詰めました。主菜は日替りで毎日2種類ご用意しています。\nグリル野菜や週替りの野菜のポタージュ付きのお弁当も。べじはんの良さをふんだんに盛り込みました。\n温かいごはんは宮城県産のひとめぼれ。お腹も心も満たされますように。そんなお弁当を毎日ご用意しております。",
      at: [0,55], width: 650, height: 40,size:11, leading: 3)
    image 'app/assets/images/logo.png', at: [680, 40], width: 100

  end
end
