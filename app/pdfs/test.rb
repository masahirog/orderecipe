require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class Test < Prawn::Document
  def initialize(daily_menu,daily_menu_details)
    super(
      page_size: 'A4',
      page_layout: :landscape,
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    left_header(daily_menu)
    right_header(daily_menu)
    left_table(daily_menu,daily_menu_details)
    # sen
    # text_box("a",at: [765,10], width: 350, height: 20,size:8)
    # text_box("a",at: [385,10], width: 350, height: 20,size:8)
  end
  # image 'app/assets/images/taberu_stamp.png', at: [440, 630], width: 60
  def left_header(daily_menu)

    stroke do
      fill_color '000000'
      fill_rounded_rectangle [-5,530], 370, 75, 4
      fill_color 'ffffff'
      text_box("<font size='18'>11</font>月<font size='18'>23</font>日（水）〜<font size='18'>11</font>月<font size='18'>29</font>日（火）",
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
    barcode = Barby::Code128.new 417
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    barcode_io.rewind
    image barcode_io, at: [-10, gyusuji_height], width: 40,height:20
    self.line_width = 1
    stroke_color 'a3a3a3'
    bounding_box([31, gyusuji_height-2], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("単品",at: [65,gyusuji_height-2], width: 350, height: 40,size:16)
    text_box("440円",at: [105,gyusuji_height-5], width: 350, height: 40,size:13)
    text_box("税込",at: [145,gyusuji_height-2], width: 350, height: 40,size:6)
    text_box("475円",at: [145,gyusuji_height-10], width: 350, height: 40,size:8)


    barcode = Barby::Code128.new 417
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    barcode_io.rewind
    image barcode_io, at: [200, gyusuji_height], width: 40,height:20
    bounding_box([240, gyusuji_height-2], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("丼",at: [270,gyusuji_height-2], width: 350, height: 40,size:16)
    text_box("640円",at: [290,gyusuji_height-5], width: 350, height: 40,size:13)
    text_box("税込",at: [335,gyusuji_height-2], width: 350, height: 40,size:6)
    text_box("691円",at: [335,gyusuji_height-10], width: 350, height: 40,size:8)


    gyusuji_height -=32 

    bounding_box([-5, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("肉増",at: [25,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("150円",at: [52,gyusuji_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [52,gyusuji_height-10], width: 350, height: 40,size:6)


    bounding_box([90, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("大根",at: [120,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("80円",at: [148,gyusuji_height], width: 350, height: 40,size:9)
    text_box("税込 86円",at: [148,gyusuji_height-10], width: 350, height: 40,size:6)

    bounding_box([185, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("温泉卵",at: [215,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("80円",at: [255,gyusuji_height], width: 350, height: 40,size:9)
    text_box("税込 86円",at: [255,gyusuji_height-10], width: 350, height: 40,size:6)

    bounding_box([290, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("煮卵",at: [320,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("80円",at: [348,gyusuji_height], width: 350, height: 40,size:9)
    text_box("税込 86円",at: [348,gyusuji_height-10], width: 350, height: 40,size:6)

  end
  def left_table(daily_menu,daily_menu_details)
    fill_color '000000'
    left_sozai_height = 345
    # text_box("週替りお惣菜　- 毎週替わるお惣菜メニューをお届けします -",at: [-5,365], width: 400, height: 40,size:13)
    text_box("<font size='16'>週替りお惣菜</font>　- 毎週替わるお惣菜メニューをお届けします -",
       inline_format: true,color:'ffffff',at: [-5,left_sozai_height], width: 400, height: 40,size:8)
    self.line_width = 2
    line [-5, left_sozai_height-20], [370, left_sozai_height-20]
    stroke_color 'd8d8d8'
    stroke
    self.line_width = 1
    stroke_color 'a3a3a3'
    number = ["①","②",'③','④','⑤','⑥','⑦','⑧','⑨','⑩','⑪','⑫','⑬','⑭','⑮','⑯','⑰','⑱','⑲','⑳','㉑','㉒','㉓','㉔','㉕','㉖','㉗','㉘','㉙']
    left_sozai_height = left_sozai_height - 30
    [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17].each do |i|
      if daily_menu_details[i].product.smaregi_code.present?
        barcode = Barby::Code128.new daily_menu_details[i].product.smaregi_code
        barcode_blob = Barby::PngOutputter.new(barcode).to_png
        barcode_io = StringIO.new(barcode_blob)
        barcode_io.rewind
      end
      left_sozai_height = 530 if i == 11
      if i < 11
        image barcode_io, at: [-10,left_sozai_height], width: 40,height:20 if daily_menu_details[i].product.smaregi_code.present?
        bounding_box([31, left_sozai_height-2], width: 26, height: 16) do
          stroke_bounds
        end
        if daily_menu_details[i].product.warm_flag == true
          fill_color 'ea9999'
          text_box("●",at: [63,left_sozai_height-4], width: 350, height: 40,size:12)
        end
        fill_color '000000'
        text_box(number[i-1],at: [80,left_sozai_height-4], width: 350, height: 40,size:12)
        text_box(daily_menu_details[i].product.name,at: [95,left_sozai_height], width: 220, height: 20,size:10, valign: :center)
        text_box("#{daily_menu_details[i].product.sell_price}円",at: [317,left_sozai_height-5], width: 350, height: 40,size:10)
        text_box("税込",at: [350,left_sozai_height], width: 350, height: 40,size:6)
        text_box("#{daily_menu_details[i].product.tax_including_sell_price}円",at: [350,left_sozai_height-8], width: 350, height: 40,size:8)
      else
        image barcode_io, at: [395,left_sozai_height], width: 40,height:20 if daily_menu_details[i].product.smaregi_code.present?
        bounding_box([436, left_sozai_height-2], width: 26, height: 16) do
          stroke_bounds
        end
        if daily_menu_details[i].product.warm_flag == true
          fill_color 'ea9999'
          text_box("●",at: [468,left_sozai_height-4], width: 350, height: 40,size:12)
        end
        fill_color '000000'
        text_box(number[i-1],at: [485,left_sozai_height-4], width: 30, height: 40,size:12)
        text_box(daily_menu_details[i].product.name,at: [500,left_sozai_height], width: 220, height: 40,size:10)
        text_box("#{daily_menu_details[i].product.sell_price}円",at: [722,left_sozai_height-5], width: 350, height: 40,size:10)
        text_box("税込",at: [755,left_sozai_height], width: 350, height: 40,size:6)
        text_box("#{daily_menu_details[i].product.tax_including_sell_price}円",at: [755,left_sozai_height-8], width: 350, height: 40,size:8)
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
    stroke_color 'a3a3a3'

    bento_height = 288
    bounding_box([436, bento_height-15], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("⑳日替わり弁当 お肉 ㉑日替わり弁当 お魚",at: [485,bento_height-15], width: 220, height: 40,size:10)
    text_box("780/840円",at: [680,bento_height-17], width: 350, height: 40,size:10)
    text_box("税込",at: [755,bento_height-17], width: 350, height: 40,size:6)
    text_box("842/907円",at: [735,bento_height-25], width: 350, height: 40,size:8)


    down_height = 32
    bento_height = bento_height - down_height
    
    barcode = Barby::Code128.new 417
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    image barcode_io, at: [395,bento_height-13], width: 40,height:20

    bounding_box([436, bento_height-15], width: 26, height: 16) do
      stroke_bounds
    end
    text_box(number[21],at: [485,bento_height-15], width: 350, height: 40,size:12)
    text_box("メインが選べるセレクト弁当",at: [500,bento_height-15], width: 220, height: 40,size:10)
    text_box("お惣菜の価格 ＋",at: [660,bento_height-17], width: 350, height: 40,size:8)
    text_box("500円",at: [720,bento_height-17], width: 350, height: 40,size:12)
    text_box("税込",at: [755,bento_height-17], width: 350, height: 40,size:6)
    text_box("540円",at: [755,bento_height-25], width: 350, height: 40,size:8)


    bento_height -= down_height
    if daily_menu_details[23].product.smaregi_code.present?
      barcode = Barby::Code128.new daily_menu_details[23].product.smaregi_code
      barcode_blob = Barby::PngOutputter.new(barcode).to_png
      barcode_io = StringIO.new(barcode_blob)
      image barcode_io, at: [395,bento_height-13], width: 40,height:20
    end

    bounding_box([436, bento_height-15], width: 26, height: 16) do
      stroke_bounds
    end
    text_box(number[22],at: [485,bento_height-15], width: 350, height: 40,size:12)
    text_box(daily_menu_details[23].product.name,at: [500,bento_height-15], width: 220, height: 40,size:10)
    text_box("#{daily_menu_details[23].product.sell_price}円",at: [720,bento_height-17], width: 350, height: 40,size:12)
    text_box("税込",at: [755,bento_height-17], width: 350, height: 40,size:6)
    text_box("#{daily_menu_details[23].product.tax_including_sell_price}円",at: [755,bento_height-25], width: 350, height: 40,size:8)


    bento_height -= down_height
    
    barcode = Barby::Code128.new 417
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    image barcode_io, at: [395,bento_height-13], width: 40,height:20

    bounding_box([436, bento_height-15], width: 26, height: 16) do
      stroke_bounds
    end
    text_box(number[23],at: [485,bento_height-15], width: 350, height: 40,size:12)
    text_box("「宮城県産 ひとめぼれ」白米・玄米",at: [500,bento_height-15], width: 220, height: 40,size:10)
    text_box("840円",at: [720,bento_height-17], width: 350, height: 40,size:12)
    text_box("税込",at: [755,bento_height-17], width: 350, height: 40,size:6)
    text_box("540円",at: [755,bento_height-25], width: 350, height: 40,size:8)




    other_height = 145
    text_box("その他商品",at: [395,other_height], width: 400, height: 40,size:13)
    self.line_width = 2
    line [395, other_height-17], [770, other_height-17]
    stroke_color 'd8d8d8'
    stroke
    self.line_width = 1

    other_height = 120

    stroke_color 'a3a3a3'
    bounding_box([395, other_height], width: 26, height: 16) do
      stroke_bounds
    end

    text_box("手提げ袋 中",at: [425,other_height], width: 350, height: 40,size:9)
    text_box("150円",at: [490,other_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [490,other_height-10], width: 350, height: 40,size:6)


    bounding_box([535, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("手提げ袋 大",at: [565,other_height], width: 350, height: 40,size:9)
    text_box("150円",at: [620,other_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [620,other_height-10], width: 350, height: 40,size:6)

    bounding_box([665, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("紙袋",at: [695,other_height], width: 350, height: 40,size:9)
    text_box("150円",at: [750,other_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [750,other_height-10], width: 350, height: 40,size:6)


    other_height -= down_height


    bounding_box([395, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("手提げ袋 中",at: [425,other_height], width: 350, height: 40,size:9)
    text_box("150円",at: [490,other_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [490,other_height-10], width: 350, height: 40,size:6)


    bounding_box([535, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("手提げ袋 大",at: [565,other_height], width: 350, height: 40,size:9)
    text_box("120円",at: [620,other_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [620,other_height-10], width: 350, height: 40,size:6)

    bounding_box([665, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("紙袋",at: [695,other_height], width: 350, height: 40,size:9)
    text_box("120円",at: [750,other_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [750,other_height-10], width: 350, height: 40,size:6)


    other_height -= down_height


    bounding_box([395, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("手提げ袋 中",at: [425,other_height], width: 350, height: 40,size:9)
    text_box("150円",at: [490,other_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [490,other_height-10], width: 350, height: 40,size:6)


    bounding_box([535, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("手提げ袋 大",at: [565,other_height], width: 350, height: 40,size:9)
    text_box("90円",at: [620,other_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [620,other_height-10], width: 350, height: 40,size:6)

    bounding_box([665, other_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("紙袋",at: [695,other_height], width: 350, height: 40,size:9)
    text_box("90円",at: [750,other_height], width: 350, height: 40,size:9)
    text_box("税込 162円",at: [750,other_height-10], width: 350, height: 40,size:6)


    other_height = 25
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

  def sen
    stroke_axis
  end
end
