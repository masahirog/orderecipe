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
    bento(bento_menus,dates)
  end


  def bento(bento_menus,dates)
    stroke do
      fill_color '000000'
      fill_rounded_rectangle [-5,525], 770, 80, 4
      fill_color 'ffffff'
      text_box("<font size='18'>#{dates[0].month}</font>月<font size='18'>#{dates[0].day}</font>日（水）〜  <font size='18'>#{dates[6].month}</font>月<font size='18'>#{dates[6].day}</font>日（火）",
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
    [0,1,4,5].each do |i|
      fill_color 'eeeeee'
      fill_rounded_rectangle [x,height], 380, 200, 2
      fill_color '000000'
      text_box(dates[i].strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[dates[i].wday]})"),at: [x+10,height-15], width: 360, height: 30,size:20, valign: :center,align: :center)
      text_box("① #{bento_menus[dates[i]][24].food_label_name}",at: [x+30,height-65], width: 350, height: 40,size:16)
      # text_box("#{bento_menus[dates[i]][24].sell_price}<font size='10'>円</font>",inline_format: true,at: [x+310,height-80], width: 350, height: 40,size:14)
      # text_box("税込 #{bento_menus[dates[i]][24].tax_including_sell_price}<font size='9'>円</font>",inline_format: true,at: [x+300,height-95], width: 350, height: 40,size:9)
      text_box("790/890<font size='10'>円</font>",inline_format: true,at: [x+290,height-85], width: 350, height: 40,size:14)
      text_box("税込 853/961<font size='9'>円</font>",inline_format: true,at: [x+290,height-100], width: 350, height: 40,size:9)


      text_box("② #{bento_menus[dates[i]][25].food_label_name}",at: [x+30,height-135], width: 350, height: 40,size:16)
      # text_box("#{bento_menus[dates[i]][25].sell_price}<font size='10'>円</font>",inline_format: true,at: [x+310,height-150], width: 350, height: 40,size:14)
      # text_box("税込 #{bento_menus[dates[i]][25].tax_including_sell_price}<font size='9'>円</font>",inline_format: true,at: [x+300,height-165], width: 350, height: 40,size:9)
      text_box("790/890<font size='10'>円</font>",inline_format: true,at: [x+290,height-155], width: 350, height: 40,size:14)
      text_box("税込 853/961<font size='9'>円</font>",inline_format: true,at: [x+290,height-170], width: 350, height: 40,size:9)

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
    [2,3,6,7].each do |i|
      fill_color 'eeeeee'
      fill_rounded_rectangle [x,height], 380, 200, 2
      fill_color '000000'
      text_box(dates[i].strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[dates[i].wday]})"),at: [x+10,height-15], width: 360, height: 30,size:20, valign: :center,align: :center)
      text_box("① #{bento_menus[dates[i]][24].food_label_name}",at: [x+30,height-65], width: 350, height: 40,size:16)
      text_box("790/890<font size='10'>円</font>",inline_format: true,at: [x+290,height-85], width: 350, height: 40,size:14)
      text_box("税込 853/961<font size='9'>円</font>",inline_format: true,at: [x+290,height-100], width: 350, height: 40,size:9)


      text_box("② #{bento_menus[dates[i]][25].food_label_name}",at: [x+30,height-135], width: 350, height: 40,size:16)
      text_box("790/890<font size='10'>円</font>",inline_format: true,at: [x+290,height-155], width: 350, height: 40,size:14)
      text_box("税込 853/961<font size='9'>円</font>",inline_format: true,at: [x+290,height-170], width: 350, height: 40,size:9)

      if i == 3
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
    text_box("手作りのお弁当。お肉とお魚を日替わりでご用意しております。",at: [0,80], width: 760, height: 40,size:18)
    text_box("野菜にお肉にお魚に、バランス良く詰めました。飽き辛いようにメインの主菜は、日替りで毎日2種類ご用意しています。\n副菜は週替りの野菜のお惣菜をいれた5種類にお新香。お野菜５品目を使ったサラダには、自家製の野菜すりおろしドレッシング。\n温かいごはんは宮城県産のひとめぼれ。お腹も心も満たされますように。そんなお弁当を毎日ご用意しております。",
      at: [0,55], width: 650, height: 40,size:11, leading: 3)
    image 'app/assets/images/logo.png', at: [680, 40], width: 100

  end
end
