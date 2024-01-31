require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'
require 'barby/barcode/qr_code'

class WeeklyMenu < Prawn::Document
  def initialize(daily_menu,daily_menu_details,bento_menus,next_menus,store)
    super(
      page_size: 'A4',
      page_layout: :landscape,
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    from = daily_menu.start_time
    to = from + 6

    left_header(daily_menu,from,to)
    right_header(daily_menu)
    left_table(daily_menu,daily_menu_details)
    start_new_page
    ura(bento_menus,from,to)
    ura_right(next_menus,store,from,to)
    start_new_page
    a3_ue(daily_menu,from,to,daily_menu_details)
    start_new_page
    a3_shita(daily_menu,from,to,daily_menu_details,store)
  end
  # image 'app/assets/images/taberu_stamp.png', at: [440, 630], width: 60
  def left_header(daily_menu,from,to)

    stroke do
      fill_color '000000'
      fill_rounded_rectangle [-5,530], 370, 75, 4
      fill_color 'ffffff'
      text_box("<font size='18'>#{from.month}</font>月<font size='18'>#{from.day}</font>日（水）〜<font size='18'>#{to.month}</font>月<font size='18'>#{to.day}</font>日（火）",
       inline_format: true,color:'ffffff',at: [-5,520],align: :center, width: 370, height: 40)
      text_box("今週のべじはんメニュー",at: [-5,498], width: 370, height: 40,align: :center,size:20)
      text_box("毎週水曜日にメニューがすべて入れ替わります",at: [-5,473], width: 370, height: 40,align: :center,size:9)
      fill_color 'cc0000'
      fill_rounded_rectangle [-15,540], 50, 50, 25
      fill_color 'ffffff'
      text_box("毎週\n替わる",at: [-7, cursor - 30], width: 40, height: 40,rotate: 20, rotate_around: :center,align: :center)

    end
  end
  def right_header(daily_menu)
    gyusuji_height = 445
    fill_color '000000'
    text_box("<font size='16'>名物！</font>ほろほろに煮込んだ  <font size='16'>牛すじ煮込み</font>",
     inline_format: true,color:'ffffff',at: [-5,gyusuji_height], width: 370, height: 40)

    self.line_width = 2
    line [-5, gyusuji_height-20], [370, gyusuji_height-20]
    stroke_color 'd8d8d8'
    stroke
    gyusuji_height = 415
    barcode = Barby::Code128.new 155
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    barcode_io.rewind
    image barcode_io, at: [-10, gyusuji_height], width: 50,height:25
    self.line_width = 1
    stroke_color 'd8d8d8'
    bounding_box([41, gyusuji_height-4], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("単品",at: [75,gyusuji_height-2], width: 350, height: 40,size:16)
    text_box("<font size='13'>440</font>円",at: [110,gyusuji_height-5], width: 350, height: 40,size:9,inline_format: true)
    text_box("税込",at: [145,gyusuji_height-2], width: 350, height: 40,size:6)
    text_box("<font size='8'>475</font>円",at: [145,gyusuji_height-10], width: 350, height: 40,size:6,inline_format: true)


    barcode = Barby::Code128.new 154
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    barcode_io.rewind
    image barcode_io, at: [200, gyusuji_height], width: 50,height:25
    bounding_box([250, gyusuji_height-4], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("丼",at: [280,gyusuji_height-2], width: 350, height: 40,size:16)
    text_box("<font size='13'>640</font>円",at: [300,gyusuji_height-5], width: 350, height: 40,size:9,inline_format: true)
    text_box("税込",at: [335,gyusuji_height-2], width: 350, height: 40,size:6)
    text_box("<font size='8'>691</font>円",at: [335,gyusuji_height-10], width: 350, height: 40,size:6,inline_format: true)


    gyusuji_height -=32 

    bounding_box([-5, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("肉増",at: [25,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("<font size='9'>150</font>円",at: [52,gyusuji_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 162円",at: [52,gyusuji_height-10], width: 350, height: 40,size:6)


    bounding_box([90, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("大根",at: [120,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("<font size='9'>80</font>円",at: [148,gyusuji_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 86円",at: [148,gyusuji_height-10], width: 350, height: 40,size:6)

    bounding_box([185, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("温泉卵",at: [215,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("<font size='9'>80</font>円",at: [255,gyusuji_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 86円",at: [255,gyusuji_height-10], width: 350, height: 40,size:6)

    bounding_box([290, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("煮卵",at: [320,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("<font size='9'>80</font>円",at: [348,gyusuji_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 86円",at: [348,gyusuji_height-10], width: 350, height: 40,size:6)

  end
  def left_table(daily_menu,daily_menu_details)
    fill_color '000000'
    left_sozai_height = 352
    # text_box("週替りお惣菜　- 毎週替わるお惣菜メニューをお届けします -",at: [-5,365], width: 400, height: 40,size:13)
    text_box("<font size='16'>週替りお惣菜</font>　- 毎週替わるお惣菜メニューをお届けします -",
       inline_format: true,color:'ffffff',at: [-5,left_sozai_height], width: 400, height: 40,size:8)
    self.line_width = 2
    line [-5, left_sozai_height-20], [370, left_sozai_height-20]
    stroke_color 'd8d8d8'
    stroke
    self.line_width = 1
    number = ["①","②",'③','④','⑤','⑥','⑦','⑧','⑨','⑩','⑪','⑫','⑬','⑭','⑮','⑯','⑰','⑱','⑲','⑳','㉑','㉒','㉓','㉔','㉕','㉖','㉗','㉘','㉙']
    left_sozai_height = left_sozai_height - 30
    [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,22].each do |i|
      dmd = daily_menu_details[i]
      if dmd.present?
        product = dmd.product
      else
        product = Product.find(16094)
      end
      if product.smaregi_code.present?
        barcode = Barby::Code128.new product.smaregi_code
        barcode_blob = Barby::PngOutputter.new(barcode).to_png
        barcode_io = StringIO.new(barcode_blob)
        barcode_io.rewind
      end
      left_sozai_height = 530 if i == 11
      if i < 11
        image barcode_io, at: [-10,left_sozai_height +2], width: 50,height:25 if product.smaregi_code.present?
        bounding_box([40, left_sozai_height-2], width: 26, height: 16) do
          stroke_bounds
        end
        if product.warm_flag == true
          fill_color 'ea9999'
          text_box("●",at: [67,left_sozai_height-4], width: 350, height: 40,size:12)
        end
        fill_color '000000'
        text_box(number[i-1],at: [80,left_sozai_height-4], width: 350, height: 40,size:12)
        text_box(product.food_label_name,at: [95,left_sozai_height+2], width: 210, height: 20,size:10, valign: :center)
        text_box("<font size='10'>#{product.sell_price}</font> 円",at: [317,left_sozai_height-5], width: 350, height: 40,size:8,inline_format: true)
        text_box("税込",at: [350,left_sozai_height], width: 350, height: 40,size:6)
        text_box("<font size='8'>#{product.tax_including_sell_price}</font> 円",at: [350,left_sozai_height-8], width: 350, height: 40,size:6,inline_format: true)
      else
        image barcode_io, at: [395,left_sozai_height+2], width: 50,height:25 if product.smaregi_code.present?
        bounding_box([445, left_sozai_height-2], width: 26, height: 16) do
          stroke_bounds
        end
        if product.warm_flag == true
          fill_color 'ea9999'
          text_box("●",at: [472,left_sozai_height-4], width: 350, height: 40,size:12)
        end
        fill_color '000000'
        text_box(number[i-1],at: [485,left_sozai_height-4], width: 30, height: 40,size:12)
        text_box(product.food_label_name,at: [500,left_sozai_height+2], width: 210, height: 20,size:10, valign: :center)
        text_box("<font size='10'>#{product.sell_price}</font> 円",at: [722,left_sozai_height-5], width: 350, height: 40,size:8,inline_format: true)
        text_box("税込",at: [755,left_sozai_height], width: 350, height: 40,size:6)
        text_box("<font size='8'>#{product.tax_including_sell_price}</font> 円",at: [755,left_sozai_height-8], width: 350, height: 40,size:6,inline_format: true)
      end
      left_sozai_height -= 32
    end
    bento_height = 303
    text_box("<font size='16'>お弁当・ご飯</font>　- 日替わりお弁当の内容は裏面に -",
       inline_format: true,color:'ffffff',at: [395,bento_height], width: 400, height: 40,size:8)

    self.line_width = 2
    line [395, bento_height-20], [770, bento_height-20]
    stroke_color 'd8d8d8'
    stroke
    self.line_width = 1

    bento_height = 288
    bounding_box([445, bento_height-15], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("⑳日替わり弁当 お肉 ㉑日替わり弁当 お魚",at: [485,bento_height-15], width: 220, height: 40,size:10)
    text_box("<font size='10'>780/840</font> 円",at: [700,bento_height-15], width: 350, height: 40,size:8,inline_format: true)
    text_box("税込",at: [755,bento_height-20], width: 350, height: 40,size:6)
    text_box("842/907円",at: [740,bento_height-26], width: 350, height: 40,size:7)


    down_height = 32
    bento_height = bento_height - down_height
    
    barcode = Barby::Code128.new 467
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    image barcode_io, at: [395,bento_height-11], width: 50,height:25

    bounding_box([445, bento_height-15], width: 26, height: 16) do
      stroke_bounds
    end
    text_box(number[21],at: [485,bento_height-15], width: 350, height: 40,size:12)
    text_box("メインが選べるセレクト弁当",at: [500,bento_height-15], width: 220, height: 40,size:10)
    text_box("お惣菜の価格 ＋",at: [660,bento_height-18], width: 350, height: 40,size:8)
    text_box("<font size='10'>500</font> 円",at: [720,bento_height-17], width: 350, height: 40,size:8,inline_format: true)
    text_box("税込",at: [755,bento_height-14], width: 350, height: 40,size:6)
    text_box("540円",at: [755,bento_height-20], width: 350, height: 40,size:8)


    bento_height -= down_height
    if daily_menu_details[23].product.smaregi_code.present?
      barcode = Barby::Code128.new daily_menu_details[23].product.smaregi_code
      barcode_blob = Barby::PngOutputter.new(barcode).to_png
      barcode_io = StringIO.new(barcode_blob)
      image barcode_io, at: [395,bento_height-11], width: 50,height:25
    end

    bounding_box([445, bento_height-15], width: 26, height: 16) do
      stroke_bounds
    end
    text_box(number[22],at: [485,bento_height-15], width: 350, height: 40,size:12)
    text_box(daily_menu_details[23].product.food_label_name,at: [500,bento_height-15], width: 220, height: 40,size:10)
    text_box("<font size='10'>#{daily_menu_details[23].product.sell_price}</font> 円",at: [720,bento_height-17], width: 350, height: 40,size:8,inline_format: true)
    text_box("税込",at: [755,bento_height-14], width: 350, height: 40,size:6)
    text_box("#{daily_menu_details[23].product.tax_including_sell_price}円",at: [755,bento_height-20], width: 350, height: 40,size:8)


    bento_height -= down_height
    
    barcode = Barby::Code128.new 132
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    image barcode_io, at: [395,bento_height-11], width: 50,height:25

    bounding_box([445, bento_height-15], width: 26, height: 16) do
      stroke_bounds
    end
    text_box(number[23],at: [485,bento_height-15], width: 350, height: 40,size:12)
    text_box("「宮城県産 ひとめぼれ」白米・玄米",at: [500,bento_height-15], width: 220, height: 40,size:10)
    text_box("<font size='10'>150</font> 円",at: [720,bento_height-17], width: 350, height: 40,size:8,inline_format: true)
    text_box("税込",at: [755,bento_height-14], width: 350, height: 40,size:6)
    text_box("162円",at: [755,bento_height-20], width: 350, height: 40,size:8)




    other_height = 145
    text_box("その他商品",at: [395,other_height], width: 400, height: 40,size:13)
    self.line_width = 2
    line [395, other_height-17], [770, other_height-17]
    stroke_color 'd8d8d8'
    stroke
    self.line_width = 1

    other_height = 120

    bounding_box([395, other_height], width: 26, height: 16) do
      stroke_bounds
    end

    text_box("手提げ袋 中",at: [425,other_height-5], width: 350, height: 40,size:9)
    text_box("<font size='9'>5</font> 円",at: [490,other_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 5円",at: [490,other_height-10], width: 350, height: 40,size:6)


    bounding_box([535, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("手提げ袋 大",at: [565,other_height-5], width: 350, height: 40,size:9)
    text_box("<font size='9'>10</font> 円",at: [620,other_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 10円",at: [620,other_height-10], width: 350, height: 40,size:6)

    bounding_box([665, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("紙袋",at: [695,other_height-5], width: 350, height: 40,size:9)
    text_box("<font size='9'>50</font> 円",at: [750,other_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 54円",at: [750,other_height-10], width: 350, height: 40,size:6)


    other_height -= down_height


    bounding_box([395, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("お〜いお茶",at: [425,other_height-5], width: 350, height: 40,size:9)
    text_box("<font size='9'>150</font> 円",at: [490,other_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 162円",at: [490,other_height-10], width: 350, height: 40,size:6)


    bounding_box([535, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("美噌元味噌汁",at: [565,other_height-5], width: 350, height: 40,size:9)
    text_box("<font size='9'>180</font> 円",at: [620,other_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 194円",at: [620,other_height-10], width: 350, height: 40,size:6)

    bounding_box([665, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("山椒・七味",at: [695,other_height-5], width: 350, height: 40,size:9)
    text_box("<font size='9'>20</font> 円",at: [750,other_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 21円",at: [750,other_height-10], width: 350, height: 40,size:6)


    other_height -= down_height


    bounding_box([395, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("ご飯 大盛り",at: [425,other_height-5], width: 350, height: 40,size:9)
    text_box("<font size='9'>20</font> 円",at: [490,other_height], width: 350, height: 40,size:6,inline_format: true)
    text_box("税込 21円",at: [490,other_height-10], width: 350, height: 40,size:6)


    bounding_box([535, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    line [560, other_height-20], [660, other_height-20]
    stroke_color 'd8d8d8'
    stroke


    bounding_box([665, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    line [690, other_height-20], [770, other_height-20]
    stroke_color 'd8d8d8'
    stroke


    other_height = 25
    bounding_box([270, other_height-15], width: 20, height: 10) do
      stroke_color 'd8d8d8'
      stroke_bounds
    end
    text_box("数量を",size:7,at: [245,other_height-17])
    text_box("内にご記入ください。",size:7,at: [300,other_height-17])

    stroke do
      stroke_color 'd8d8d8'
      rounded_rectangle [395, other_height], 80, 20, 2
      text_box("　合計数：",size:8,at: [395,other_height-7])
    end
    stroke do
      fill_color 'd8d8d8'
      fill_rounded_rectangle [490, other_height], 290, 20, 2
      fill_color 'ea9999'
      text_box("●",size:7,at: [495,other_height-7])
      fill_color '000000'
      text_box(" の付いている商品は、電子レンジ 500Wで1分程を目安で温めてお召し上がり下さい",size:7,at: [505,other_height-7])
    end

  end
  def ura(bento_menus,from,to)
    stroke do
      fill_color '000000'
      fill_rounded_rectangle [-5,530], 370, 60, 4
      fill_color 'ffffff'
      text_box("#{from.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[from.wday]})")}〜 #{to.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[to.wday]})")}",inline_format: true,color:'ffffff',at: [-5,520],align: :center, width: 370, height: 40)
      text_box("日替わりお弁当",at: [-5,502], width: 370, height: 40,align: :center,size:20)
    end
    fill_color '000000'
    fill_color "2626ff"
    height = 440
    bento_menus.each do |bm|
      bento_height = height +16
      date = bm[0].strftime("%-m月%-d日\n(#{%w(日 月 火 水 木 金 土)[bm[0].wday]})")
      if bm[0].wday == 6
        fill_color "2626ff"
      elsif bm[0].wday == 0
        fill_color "d43732"
      else
        fill_color "000000"
      end
      text_box(date,at: [-10,height], width: 45, height: 180,size:9,align: :center)
      fill_color "000000"
      bm[1].each_with_index do |data|
        product = data[1]
        if product.smaregi_code.present?
          barcode = Barby::Code128.new product.smaregi_code
          barcode_blob = Barby::PngOutputter.new(barcode).to_png
          barcode_io = StringIO.new(barcode_blob)
          barcode_io.rewind
        end

        image barcode_io, at: [35,bento_height+2], width: 50,height:25 if product.smaregi_code.present?
        stroke_color 'd8d8d8'
        bounding_box([86, bento_height-2], width: 26, height: 16) do
          stroke_bounds
        end
        text_box(product.food_label_name,at: [115,bento_height], width: 200, height: 20,size:9, valign: :center)
        text_box("<font size='10'>#{product.sell_price}</font> 円",at: [318,bento_height-5], width: 100, height: 40,size:8,inline_format: true)
        text_box("税込",at: [350,bento_height], width: 350, height: 40,size:5)
        text_box("<font size='7'>#{product.tax_including_sell_price}</font> 円",at: [350,bento_height-8], width: 350, height: 40,size:5,inline_format: true)
        bento_height -= 28
      end
      line [0, bento_height-5], [370, bento_height-3]
      stroke

      height -= 70
    end
  end
  def ura_right(next_menus,store,from,to)
    stroke do
      fill_color 'd8d8d8'
      fill_rounded_rectangle [400,530], 370, 60, 4
      fill_color '000000'
      text_box("#{(from+7).strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[(from+7).wday]})")}〜 #{(to+7).strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[(to+7).wday]})")}",inline_format: true,color:'ffffff',at: [400,520],align: :center, width: 370, height: 40)
      text_box("翌週の週替りお惣菜",at: [400,502], width: 370, height: 40,align: :center,size:20)
    end
    fill_color '000000'
    height = 460
    next_menus.each do |product|
      if product.warm_flag == true
        fill_color 'ea9999'
        text_box("●",at: [400,height-4], width: 350, height: 40,size:12)
      end
      fill_color "000000"
      text_box(product.food_label_name,at: [420,height], width: 250, height: 20,size:9, valign: :center)
      text_box("<font size='10'>#{product.sell_price}</font> 円",at: [718,height-5], width: 100, height: 40,size:8,inline_format: true)
      text_box("税込",at: [750,height], width: 100, height: 40,size:5)
      text_box("<font size='7'>#{product.tax_including_sell_price}</font> 円",at: [750,height-7], width: 200, height: 40,size:5,inline_format: true)
      height -= 20
    end
    text_box("※メニューは仕入れ状況等によって変動する場合がございます。",at: [545,height-5], width: 300, height: 40,size:8)
    # dash(8, space: 2, phase: 1)
    # stroke_horizontal_line 400, 770, at: 100

    self.line_width = 2
    line [400, 100], [770, 100]
    stroke_color 'd8d8d8'
    stroke



    fill_color 'eeeeee'
    fill_rounded_rectangle [400,90], 180, 60, 2
    fill_color '000000'
    text_box("ポイントサービス",at: [410,83], width: 110, height: 40,size:11)
    text_box("お買上げ100円で1ポイントたまるポイントカードをご用意しています！QRコードよりご登録いただけます",at: [410,70], width: 110, height: 40,size:8)
    if store.line_url.present?
      qr_code = Barby::QrCode.new(store.line_url)
      barcode_blob = Barby::PngOutputter.new(qr_code).to_png(margin: 2)
      barcode_io = StringIO.new(barcode_blob)
      barcode_io.rewind
      image barcode_io, at: [534,80], width: 40      
    end

    fill_color 'eeeeee'
    fill_rounded_rectangle [590,90], 180, 60, 2
    fill_color '000000'
    text_box("予約お取り置き",at: [600,83], width: 110, height: 40,size:11)
    text_box("お惣菜のお取り置き予約が可能です。時間に合わせてご用意しますので、お渡しもスムーズです。",at: [600,70], width: 110, height: 40,size:8)
    if store.yoyaku_url.present?
      qr_code = Barby::QrCode.new(store.yoyaku_url)
      barcode_blob = Barby::PngOutputter.new(qr_code).to_png(margin: 2)
      barcode_io = StringIO.new(barcode_blob)
      barcode_io.rewind
      image barcode_io, at: [724,80], width: 40
    end

    image 'app/assets/images/logo.png', at: [410, 10], width: 100
    text_box("#{store.name}　#{store.address}",at: [520,12], width: 280, height: 40,size:8)
    text_box("TEL：#{store.phone}　営業時間： 11:00-21:00（無休）",at: [520,-2], width: 280, height: 40,size:8)
  end


  def a3_ue(daily_menu,from,to,daily_menu_details)

    stroke do
      fill_color '000000'
      fill_rounded_rectangle [-5,525], 770, 80, 4
      fill_color 'ffffff'
      text_box("<font size='18'>#{from.month}</font>月<font size='18'>#{from.day}</font>日（水）〜<font size='18'>#{to.month}</font>月<font size='18'>#{to.day}</font>日（火）",
       inline_format: true,color:'ffffff',at: [-5,515],align: :center, width: 770, height: 40)
      text_box("今週のべじはんメニュー",at: [-5,493], width: 770, height: 40,align: :center,size:20)
      text_box("毎週水曜日にメニューがすべて入れ替わります",at: [-5,468], width: 770, height: 40,align: :center,size:9)
      fill_color 'cc0000'
      fill_rounded_rectangle [-20,540], 60, 60, 30
      fill_color 'ffffff'
      text_box("毎週\n替わる",at: [-7, cursor - 35], width: 40, height: 40,rotate: 20, rotate_around: :center,align: :center,size:13)
    end
    gyusuji_height = 430
    fill_color '000000'
    text_box("<font size='16'>名物！</font>ほろほろに煮込んだ  <font size='16'>牛すじ煮込み</font>",
     inline_format: true,color:'ffffff',at: [-5,gyusuji_height], width: 370, height: 40)

    self.line_width = 2
    line [-5, gyusuji_height-20], [370, gyusuji_height-20]
    stroke_color 'd8d8d8'
    stroke
    gyusuji_height = 400
    text_box("煮込み <font size='20'>単品</font>",at: [0,gyusuji_height-2], width: 350, height: 40,size:14,inline_format: true)
    text_box("<font size='13'>440</font>円",at: [95,gyusuji_height-10], width: 350, height: 40,size:10,inline_format: true)
    text_box("税込",at: [135,gyusuji_height-7], width: 350, height: 40,size:6)
    text_box("<font size='8'>475</font>円",at: [135,gyusuji_height-15], width: 350, height: 40,size:6,inline_format: true)


    text_box("煮込み <font size='20'>丼</font>",at: [210,gyusuji_height-2], width: 350, height: 40,size:14,inline_format: true)
    text_box("<font size='13'>640</font>円",at: [290,gyusuji_height-10], width: 350, height: 40,size:10,inline_format: true)
    text_box("税込",at: [335,gyusuji_height-7], width: 350, height: 40,size:6)
    text_box("<font size='8'>691</font>円",at: [335,gyusuji_height-15], width: 350, height: 40,size:6,inline_format: true)

    gyusuji_height -=40
    text_box(" ー 選べるオプション ー",at: [0,gyusuji_height], width: 350, height: 40,size:10)
    gyusuji_height -=20 

    text_box("1.肉増",at: [10,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("150円",at: [52,gyusuji_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [52,gyusuji_height-10], width: 350, height: 40,size:6)


    text_box("2.大根",at: [105,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("80円",at: [147,gyusuji_height], width: 350, height: 40,size:9)
    text_box("税込 86円",at: [147,gyusuji_height-10], width: 350, height: 40,size:6)

    text_box("3.温泉卵",at: [195,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("80円",at: [250,gyusuji_height], width: 350, height: 40,size:9)
    text_box("税込 86円",at: [250,gyusuji_height-10], width: 350, height: 40,size:6)

    text_box("4.煮卵",at: [300,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("80円",at: [338,gyusuji_height], width: 350, height: 40,size:9)
    text_box("税込 86円",at: [338,gyusuji_height-10], width: 350, height: 40,size:6)

    fill_color '000000'
    left_sozai_height = 300
    # text_box("週替りお惣菜　- 毎週替わるお惣菜メニューをお届けします -",at: [-5,365], width: 400, height: 40,size:13)
    text_box("<font size='16'>週替りお惣菜</font>　- 毎週替わるお惣菜メニューをお届けします -",
       inline_format: true,color:'ffffff',at: [-5,left_sozai_height], width: 400, height: 40,size:10)
    self.line_width = 2
    line [-5, left_sozai_height-20], [370, left_sozai_height-20]
    stroke_color 'd8d8d8'
    stroke
    self.line_width = 1
    stroke_color 'a3a3a3'
    number = ["①","②",'③','④','⑤','⑥','⑦','⑧','⑨','⑩','⑪','⑫','⑬','⑭','⑮','⑯','⑰','⑱','⑲','⑳','㉑','㉒','㉓','㉔','㉕','㉖','㉗','㉘','㉙']
    left_sozai_height = left_sozai_height - 30
    [1,2,3,4,12,13,14,15,16,22].each do |i|
      dmd = daily_menu_details[i]
      if dmd.present?
        product = dmd.product
      else
        product = Product.find(16094)
      end

      left_sozai_height = 410 if i == 12
      if i < 12
        if product.warm_flag == true
          fill_color 'ea9999'
          text_box("●",at: [-5,left_sozai_height-8], width: 350, height: 40,size:14)
        end
        fill_color '000000'
        text_box(number[i-1],at: [15,left_sozai_height-8], width: 350, height: 40,size:14)
        text_box(product.food_label_name,at: [35,left_sozai_height], width: 250, height: 30,size:14, valign: :center)
        text_box("#{product.sell_price}<font size='10'>円</font>",inline_format: true,at: [310,left_sozai_height-5], width: 350, height: 40,size:14)
        text_box("税込",at: [350,left_sozai_height-5], width: 350, height: 40,size:6)
        text_box("#{product.tax_including_sell_price}円",at: [350,left_sozai_height-12], width: 350, height: 40,size:8)
        text_box(product.contents,at: [40,left_sozai_height-30], width: 320, height: 30,size:9, valign: :center)
      else
        
        if product.warm_flag == true
          fill_color 'ea9999'
          text_box("●",at: [410,left_sozai_height-8], width: 350, height: 40,size:14)
        end
        fill_color '000000'
        text_box(number[i-1],at: [430,left_sozai_height-8], width: 30, height: 40,size:14)
        text_box(product.food_label_name,at: [450,left_sozai_height], width: 250, height: 30,size:14, valign: :center)
        text_box("#{product.sell_price}<font size='10'>円</font>",inline_format: true,at: [705,left_sozai_height-5], width: 350, height: 40,size:14)
        text_box("税込",at: [745,left_sozai_height-5], width: 350, height: 40,size:6)
        text_box("#{product.tax_including_sell_price}円",at: [745,left_sozai_height-12], width: 350, height: 40,size:8)
        text_box(product.contents,at: [455,left_sozai_height-30], width: 320, height: 30,size:9, valign: :center)
      end
      left_sozai_height -= 70
    end
  end


  def a3_shita(daily_menu,from,to,daily_menu_details,store)
    number = ["①","②",'③','④','⑤','⑥','⑦','⑧','⑨','⑩','⑪','⑫','⑬','⑭','⑮','⑯','⑰','⑱','⑲','⑳','㉑','㉒','㉓','㉔','㉕','㉖','㉗','㉘','㉙']
    left_sozai_height = 520
    [5,6,7,8,9,10,11].each do |i|
      left_sozai_height = 410 if i == 12
      dmd = daily_menu_details[i]
      if dmd.present?
        product = dmd.product
      else
        product = Product.find(16094)
      end
      if product.warm_flag == true
        fill_color 'ea9999'
        text_box("●",at: [-5,left_sozai_height-8], width: 350, height: 40,size:14)
      end
      fill_color '000000'
      text_box(number[i-1],at: [15,left_sozai_height-8], width: 350, height: 40,size:14)
      text_box(product.food_label_name,at: [35,left_sozai_height], width: 250, height: 30,size:14, valign: :center)
      text_box("#{product.sell_price}<font size='10'>円</font>",inline_format: true,at: [310,left_sozai_height-5], width: 350, height: 40,size:14)
      text_box("税込",at: [350,left_sozai_height-5], width: 350, height: 40,size:6)
      text_box("#{product.tax_including_sell_price}円",at: [350,left_sozai_height-12], width: 350, height: 40,size:8)
      text_box(product.contents,at: [40,left_sozai_height-30], width: 320, height: 30,size:9, valign: :center)
      left_sozai_height -= 65
    end

    right_height = 510
    text_box("<font size='16'>お弁当</font>　  - お弁当は日替わり、美味しいと評判のお米は宮城県産 -",
       inline_format: true,color:'ffffff',at: [410,right_height], width: 400, height: 40,size:10)
    self.line_width = 2
    line [410, right_height-20], [785, right_height-20]
    stroke_color 'd8d8d8'
    stroke
    self.line_width = 1

    right_height -= 40

    fill_color 'ea9999'
    text_box("●",at: [410,right_height-4], width: 350, height: 40,size:14)
    fill_color '000000'
    text_box("⑳",at: [430,right_height-4], width: 30, height: 40,size:14)
    text_box("本日のお肉のお弁当",at: [450,right_height+5], width: 250, height: 30,size:14, valign: :center)
    text_box("780/840<font size='10'>円</font>",inline_format: true,at: [645,right_height-5], width: 350, height: 40,size:14)
    text_box("税込",at: [745,right_height-5], width: 350, height: 40,size:6)
    text_box("842/907円",at: [725,right_height-12], width: 350, height: 40,size:8)
    text_box("毎日主菜が入れ替わるお弁当です。主菜はお肉を使ったお料理です。",at: [455,right_height-25], width: 320, height: 30,size:9, valign: :center)

    right_height -= 75

    fill_color 'ea9999'
    text_box("●",at: [410,right_height-4], width: 350, height: 40,size:14)
    fill_color '000000'
    text_box("㉑",at: [430,right_height-4], width: 30, height: 40,size:14)
    text_box("本日のお魚のお弁当",at: [450,right_height+5], width: 250, height: 30,size:14, valign: :center)
    text_box("780/840<font size='10'>円</font>",inline_format: true,at: [645,right_height-5], width: 350, height: 40,size:14)
    text_box("税込",at: [745,right_height-5], width: 350, height: 40,size:6)
    text_box("842/907円",at: [725,right_height-12], width: 350, height: 40,size:8)
    text_box("毎日主菜が入れ替わるお弁当です。主菜はお魚を使ったお料理です。",at: [455,right_height-25], width: 280, height: 30,size:9, valign: :center)

    right_height -= 75

    fill_color 'ea9999'
    text_box("●",at: [410,right_height-4], width: 350, height: 40,size:14)
    fill_color '000000'
    text_box("㉒",at: [430,right_height-4], width: 30, height: 40,size:14)
    text_box("メインのおかずが選べる「セレクト弁当」",at: [450,right_height+5], width: 250, height: 30,size:13, valign: :center)
    text_box("500<font size='10'>円</font>",inline_format: true,at: [705,right_height-5], width: 350, height: 40,size:14)
    text_box("税込",at: [745,right_height-5], width: 350, height: 40,size:6)
    text_box("540円",at: [745,right_height-12], width: 350, height: 40,size:8)
    text_box("ショーケースから好きなお惣菜1品お選び頂けます。お惣菜の価格+500円で好きなお惣菜を1品入れたお弁当が出来上がります。",at: [455,right_height-25], width: 280, height: 30,size:9, valign: :center)

    right_height -= 75

    fill_color 'ea9999'
    text_box("●",at: [410,right_height-4], width: 350, height: 40,size:14)
    fill_color '000000'
    text_box("㉓",at: [430,right_height-4], width: 30, height: 40,size:14)
    text_box(daily_menu_details[23].product.food_label_name,at: [450,right_height+5], width: 250, height: 30,size:14, valign: :center)
    text_box("780<font size='10'>円</font>",inline_format: true,at: [705,right_height-5], width: 350, height: 40,size:14)
    text_box("税込",at: [745,right_height-5], width: 350, height: 40,size:6)
    text_box("840円",at: [745,right_height-12], width: 350, height: 40,size:8)
    text_box(daily_menu_details[23].product.contents,at: [455,right_height-25], width: 280, height: 30,size:9, valign: :center)


    right_height -= 75

    fill_color 'ea9999'
    text_box("●",at: [410,right_height-4], width: 350, height: 40,size:14)
    fill_color '000000'
    text_box("㉔",at: [430,right_height-4], width: 30, height: 40,size:14)
    text_box("「宮城県産 ひとめぼれ」白米・玄米",at: [450,right_height+5], width: 250, height: 30,size:14, valign: :center)
    text_box("150<font size='10'>円</font>",inline_format: true,at: [705,right_height-5], width: 350, height: 40,size:14)
    text_box("税込",at: [745,right_height-5], width: 350, height: 40,size:6)
    text_box("162円",at: [745,right_height-12], width: 350, height: 40,size:8)
    text_box("べじはんの白ごはんは、宮城県産のひとめぼれを使用しています。おかずの味を引き立てる、程よい甘みと食感もよい。",at: [455,right_height-25], width: 280, height: 30,size:9, valign: :center)


    self.line_width = 2
    line [0, 50], [770, 50]
    stroke_color 'd8d8d8'
    stroke


    fill_color 'eeeeee'
    fill_rounded_rectangle [460,34], 310, 40, 2
    fill_color '000000'
    text_box("<color rgb='ea9999'>●</color>の付いている商品は、電子レンジで温めてお召し上がりください。500Wで1分が目安です。",at: [470,30], width: 280, height: 30,size:10, valign: :center,inline_format: true)

    image 'app/assets/images/logo.png', at: [10, 30], width: 150
    text_box("#{store.name}",at: [180,32], width: 280, height: 40,size:14)
    text_box("#{store.address}",at: [180,16], width: 280, height: 40,size:10)
    text_box("TEL：#{store.phone}　営業時間： 11:00-21:00（無休）",at: [180,3], width: 280, height: 40,size:10)
  end


  def sen
    stroke_axis
  end
end
