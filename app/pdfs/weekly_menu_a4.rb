require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'
require 'barby/barcode/qr_code'

class WeeklyMenuA4 < Prawn::Document
  def initialize(daily_menu,daily_menu_details,bento_menus,next_menus,store)
    super(page_size: 'A4',page_layout: :landscape,:top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/NotoSansJP-Medium.ttf"
    from = daily_menu.start_time
    to = from + 6

    left_header(daily_menu,from,to)
    right_header(daily_menu)
    left_table_new(daily_menu,daily_menu_details)
    start_new_page
    ura_new(bento_menus,from,to)
    ura_right(next_menus,store,from,to)
  end
  # image 'app/assets/images/taberu_stamp.png', at: [440, 630], width: 60
  def left_header(daily_menu,from,to)
    stroke do
      # fill_color '000000'
      fill_color 'a9a9a9'
      fill_rounded_rectangle [-10,530], 380, 65, 4
      fill_color 'ffffff'
      text_box("<font size='18'>#{from.month}</font>月<font size='18'>#{from.day}</font>日（水）〜 <font size='18'>#{to.month}</font>月<font size='18'>#{to.day}</font>日（火）",
       inline_format: true,color:'ffffff',at: [-10,520],align: :center, width: 370, height: 40)
      text_box("今週のべじはんメニュー",at: [-10,498], width: 370, height: 40,align: :center,size:20, styles:[:bold] )
      fill_color '000000'
      fill_rounded_rectangle [-15,540], 50, 50, 25
      fill_color 'ffffff'
      text_box("毎週\n替わる",at: [-7, cursor - 30], width: 40, height: 40,rotate: 20, rotate_around: :center,align: :center)

    end
  end
  def right_header(daily_menu)
    gyusuji_height = 450
    fill_color '000000'
    text_box("<font size='16'>名物！</font>ほろほろに煮込んだ  <font size='16'>牛すじ煮込み</font>",
     inline_format: true,color:'ffffff',at: [-10,gyusuji_height], width: 370, height: 40)

    self.line_width = 2
    line [-10, gyusuji_height-20], [370, gyusuji_height-20]
    stroke_color 'd8d8d8'
    stroke
    gyusuji_height = 420
    barcode = Barby::Code128.new 155
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    barcode_io.rewind
    image barcode_io, at: [-15, gyusuji_height], width: 50,height:25
    self.line_width = 1
    stroke_color 'd8d8d8'
    bounding_box([41, gyusuji_height-4], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("単品",at: [75,gyusuji_height-2], width: 350, height: 40,size:16)
    text_box("<font size='13'>490</font>円",at: [110,gyusuji_height-5], width: 350, height: 40,size:9,inline_format: true)
    text_box("税込",at: [145,gyusuji_height-2], width: 350, height: 40,size:6)
    text_box("<font size='8'>529</font>円",at: [145,gyusuji_height-10], width: 350, height: 40,size:6,inline_format: true)

    barcode = Barby::Code128.new 154
    barcode_blob = Barby::PngOutputter.new(barcode).to_png
    barcode_io = StringIO.new(barcode_blob)
    barcode_io.rewind
    image barcode_io, at: [195, gyusuji_height], width: 50,height:25
    bounding_box([250, gyusuji_height-4], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("丼",at: [280,gyusuji_height-2], width: 350, height: 40,size:16)
    text_box("<font size='13'>690</font>円",at: [300,gyusuji_height-5], width: 350, height: 40,size:9,inline_format: true)
    text_box("税込",at: [335,gyusuji_height-2], width: 350, height: 40,size:6)
    text_box("<font size='8'>745</font>円",at: [335,gyusuji_height-10], width: 350, height: 40,size:6,inline_format: true)

    gyusuji_height -=32 

    bounding_box([-10, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("肉増",at: [25,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("<font size='9'>150</font>円",at: [52,gyusuji_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 162円",at: [52,gyusuji_height-10], width: 350, height: 40,size:6)


    bounding_box([90, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("大根",at: [120,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("<font size='9'>100</font>円",at: [148,gyusuji_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 108円",at: [148,gyusuji_height-10], width: 350, height: 40,size:6)

    bounding_box([185, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("温泉卵",at: [215,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("<font size='9'>100</font>円",at: [255,gyusuji_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 108円",at: [255,gyusuji_height-10], width: 350, height: 40,size:6)

    bounding_box([290, gyusuji_height], width: 26, height: 16) do
      stroke_bounds
    end
    text_box("煮卵",at: [320,gyusuji_height-2], width: 350, height: 40,size:12)
    text_box("<font size='9'>100</font>円",at: [348,gyusuji_height], width: 350, height: 40,size:7,inline_format: true)
    text_box("税込 108円",at: [348,gyusuji_height-10], width: 350, height: 40,size:6)

  end

  def ura_right(next_menus,store,from,to)
    stroke do
      fill_color 'a9a9a9'
      fill_rounded_rectangle [460,530], 310, 60, 4
      fill_color 'ffffff'
      text_box("#{(from+7).strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[(from+7).wday]})")}〜 #{(to+7).strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[(to+7).wday]})")}",inline_format: true,color:'ffffff',at: [460,520],align: :center, width: 310, height: 40)
      text_box("翌週の週替りお惣菜",at: [460,502], width: 310, height: 40,align: :center,size:20)
    end
    fill_color '000000'
    height = 460
    next_menus.each do |product|
      if product.warm_flag == true
        fill_color '000000'
        text_box("●",at: [460,height-4], width: 350, height: 40,size:12)
      end
      fill_color "000000"
      text_box(product.food_label_name,at: [480,height], width: 230, height: 20,size:9, valign: :center)
      text_box("<font size='10'>#{product.sell_price}</font> 円",at: [718,height-5], width: 100, height: 40,size:8,inline_format: true)
      text_box("税込",at: [750,height], width: 100, height: 40,size:5)
      text_box("<font size='7'>#{product.tax_including_sell_price}</font> 円",at: [750,height-7], width: 200, height: 40,size:5,inline_format: true)
      height -= 21
    end
    text_box("※メニューは仕入れ状況等によって変動する場合がございます。",at: [545,height-5], width: 300, height: 40,size:8)
    # dash(8, space: 2, phase: 1)
    # stroke_horizontal_line 400, 770, at: 100

    # self.line_width = 2
    # line [460, 100], [770, 100]
    # stroke_color 'd8d8d8'
    # stroke



    # fill_color 'eeeeee'
    # fill_rounded_rectangle [470,145], 300, 60, 2
    # fill_color '000000'
    # text_box("予約お取り置き",at: [480,135], width: 180, height: 40,size:11)
    # text_box("お惣菜のお取り置き予約が可能です。時間に合わせてご用意しますので、お渡しもスムーズです。",at: [480,55], width: 220, height: 40,size:9)
    # if store.yoyaku_url.present?
    #   qr_code = Barby::QrCode.new(store.yoyaku_url)
    #   barcode_blob = Barby::PngOutputter.new(qr_code).to_png(margin: 2)
    #   barcode_io = StringIO.new(barcode_blob)
    #   barcode_io.rewind
    #   image barcode_io, at: [710,135], width: 40
    # end


    fill_color 'eeeeee'
    fill_rounded_rectangle [470,145], 300, 120, 2
    fill_color '000000'
    text_box("定休日・営業時間変更のご案内",at: [480,135], width: 280, height: 40,size:12)
    text_box("2024年11月より、毎週月曜日と毎月第一日曜日は営業を定休日とさせて頂きます。\nまた営業時間も「11:00〜20:00」と変更いたします。\n皆さまにはご不便をおかけいたしますが、べじはんとして更に良いサービスや商品のご提供を目指してまいりますので、何卒ご理解いただけますと幸いです。",at: [480,115], width: 285, height: 100,size:10, leading: 4)


    # fill_color 'eeeeee'
    # fill_rounded_rectangle [470,80], 300, 60, 2
    # fill_color '000000'
    # text_box("ポイントサービス",at: [480,70], width: 110, height: 40,size:11)
    # text_box("お買上げ100円で1ポイントたまるポイントカードをご用意しています！QRコードよりご登録いただけます",at: [480,55], width: 220, height: 40,size:9)
    # if store.line_url.present?
    #   qr_code = Barby::QrCode.new(store.line_url)
    #   barcode_blob = Barby::PngOutputter.new(qr_code).to_png(margin: 2)
    #   barcode_io = StringIO.new(barcode_blob)
    #   barcode_io.rewind
    #   image barcode_io, at: [710,70], width: 40      
    # end

    # image 'app/assets/images/logo.png', at: [410, 10], width: 100
    text_box("#{store.name}　#{store.address}",at: [470,12], width: 280, height: 40,size:8)
    text_box("TEL：#{store.phone}　営業時間：11:00-20:00　定休日：毎月第一日曜、毎週月曜",at: [470,-2], width: 400, height: 40,size:8)
  end


  
  def sen
    stroke_axis
  end


  # ーーーーーーーーーー


  def left_table_new(daily_menu,daily_menu_details)
    fill_color '000000'
    left_sozai_height = 352
    next_day = daily_menu.start_time + 1
    next_daily_menu = DailyMenu.find_by(start_time:next_day) 
    menu_x = -10


    # left_sozai_height = left_sozai_height - 10
    text_box("<font size='14'>べじはんのお弁当 Daily Bento</font>　- 主菜の内容は裏面にございます -",
       inline_format: true,color:'ffffff',at: [menu_x,left_sozai_height], width: 400, height: 40,size:8)

    self.line_width = 2
    line [menu_x, left_sozai_height-20], [menu_x + 375, left_sozai_height-20]
    stroke_color 'd8d8d8'
    stroke
    self.line_width = 1
    
    left_sozai_height = left_sozai_height - 24
    text_box("お\n肉",size:7,at: [menu_x + 2,left_sozai_height-11])
    bounding_box([menu_x + 45, left_sozai_height-9], width: 35, height: 18) do
      stroke_bounds
    end
    text_box("お\n魚",size:7,at: [menu_x + 47,left_sozai_height-11])
    bounding_box([menu_x, left_sozai_height-9], width: 35, height: 18) do
      stroke_bounds
    end
    text_box("ナシ・ 大",size:7,at: [menu_x + 2,left_sozai_height-30])
    text_box("ナシ・ 大",size:7,at: [menu_x + 47,left_sozai_height-30])


    text_box("<font size='16'>松</font>　- 主菜、副菜３種、グリル野菜、週替りポタージュ -",at: [menu_x + 95,left_sozai_height-8], width: 320, height: 40,size:9,inline_format: true)
    text_box("<font size='10'>890〜990</font> 円",at: [menu_x + 245,left_sozai_height-28], width: 350, height: 40,size:8,inline_format: true)
    text_box("（税込 961〜1,069円）",at: [menu_x + 305,left_sozai_height-30], width: 350, height: 40,size:8)


    down_height = 35
    left_sozai_height = left_sozai_height - down_height
    text_box("お\n肉",size:7,at: [menu_x + 2,left_sozai_height-11])
    bounding_box([menu_x + 45, left_sozai_height-9], width: 35, height: 18) do
      stroke_bounds
    end
    text_box("お\n魚",size:7,at: [menu_x + 47,left_sozai_height-11])
    bounding_box([menu_x, left_sozai_height-9], width: 35, height: 18) do
      stroke_bounds
    end
    text_box("ナシ・ 大",size:7,at: [menu_x + 2,left_sozai_height-30])
    text_box("ナシ・ 大",size:7,at: [menu_x + 47,left_sozai_height-30])


    text_box("<font size='16'>竹</font>　- 主菜、副菜３種、グリル野菜 -",at: [menu_x + 95,left_sozai_height-8], width: 320, height: 40,size:9,inline_format: true)
    text_box("<font size='10'>790〜890</font> 円",at: [menu_x + 245,left_sozai_height-28], width: 350, height: 40,size:8,inline_format: true)
    text_box("（税込 853〜961円）",at: [menu_x + 305,left_sozai_height-30], width: 350, height: 40,size:8)
    

    down_height = 35
    left_sozai_height = left_sozai_height - down_height
    text_box("お\n肉",size:7,at: [menu_x + 2,left_sozai_height-11])
    bounding_box([menu_x + 45, left_sozai_height-9], width: 35, height: 18) do
      stroke_bounds
    end
    text_box("お\n魚",size:7,at: [menu_x + 47,left_sozai_height-11])
    bounding_box([menu_x, left_sozai_height-9], width: 35, height: 18) do
      stroke_bounds
    end
    text_box("ナシ・ 大",size:7,at: [menu_x + 2,left_sozai_height-30])
    text_box("ナシ・ 大",size:7,at: [menu_x + 47,left_sozai_height-30])


    text_box("<font size='16'>梅</font>　- 主菜、副菜２種、グリル野菜 -",at: [menu_x + 95,left_sozai_height-8], width: 320, height: 40,size:9,inline_format: true)
    text_box("<font size='10'>690〜790</font> 円",at: [menu_x + 245,left_sozai_height-28], width: 350, height: 40,size:8,inline_format: true)
    text_box("（税込 745〜853円）",at: [menu_x + 305,left_sozai_height-30], width: 350, height: 40,size:8)

    down_height = 32
    left_sozai_height = left_sozai_height - down_height

    text_box("お弁当は、ご飯なし（おかずのみ）の場合は商品価格より108円引きでご提供しております。",at: [menu_x + 50,left_sozai_height-20], width: 350, height: 40,size:8)

    
    left_sozai_height = left_sozai_height - 45







    [
      [[1],"<font size='12'>手作りポタージュ Potage Soup</font>　- 生産者さん直送の野菜で作ったポタージュ -"],
      [[13,14],"<font size='12'>野菜1日分の汁物 Okazu Soup</font>　- たっぷり野菜とたんぱく質も入ってボリューム満点 -"],
      [[23],"<font size='12'>ライスプレート Rice Plate</font>　- カレーライスやガパオライスなどを週替りで -"],
      [[2,3,4,5,6],"<font size='12'>副菜 Side Dish</font>　- 野菜たっぷりの副菜 -"],
      [[7,8,9,10,11,12],"<font size='12'>主菜 Main Dish</font>　- お肉、お魚でこだわりの一品 -"]
    ].each_with_index do |paper_menu_numbers,index|
      left_sozai_height = 520 if index == 3
      menu_x = 395 if index == 3
      text_box(paper_menu_numbers[1],
         inline_format: true,color:'ffffff',at: [menu_x,left_sozai_height], width: 400, height: 40,size:8)
      self.line_width = 2
      line [menu_x, left_sozai_height-18], [menu_x + 380, left_sozai_height-18]
      stroke_color 'd8d8d8'
      stroke
      self.line_width = 1
      left_sozai_height = left_sozai_height - 28

      paper_menu_numbers[0].each_with_index do |i,ii|
        dmd = daily_menu_details[i]
        if dmd.present?
          product = dmd.product
          if product.smaregi_code.present?
            barcode = Barby::Code128.new product.smaregi_code
            barcode_blob = Barby::PngOutputter.new(barcode).to_png
            barcode_io = StringIO.new(barcode_blob)
            barcode_io.rewind
          end
          if index < 3
            image barcode_io, at: [-15,left_sozai_height +2], width: 50,height:25 if product.smaregi_code.present?
            bounding_box([40, left_sozai_height-2], width: 26, height: 16) do
              stroke_bounds
            end
            if product.warm_flag == true
              fill_color '000000'
              text_box("●",at: [70,left_sozai_height-4], width: 350, height: 40,size:12)
            end
            fill_color '000000'
            text_box(product.food_label_name,at: [85,left_sozai_height+2], width: 210, height: 20,size:10, valign: :center)
            text_box("<font size='10'>#{product.sell_price}</font> 円",at: [317,left_sozai_height-5], width: 350, height: 40,size:8,inline_format: true)
            text_box("税込",at: [350,left_sozai_height], width: 350, height: 40,size:6)
            text_box("<font size='8'>#{product.tax_including_sell_price}</font> 円",at: [350,left_sozai_height-8], width: 350, height: 40,size:6,inline_format: true)
          else
            image barcode_io, at: [390,left_sozai_height+2], width: 50,height:25 if product.smaregi_code.present?
            bounding_box([445, left_sozai_height-2], width: 26, height: 16) do
              stroke_bounds
            end
            if product.warm_flag == true
              fill_color '000000'
              text_box("●",at: [475,left_sozai_height-4], width: 350, height: 40,size:12)

            end
            fill_color '000000'
            text_box(product.food_label_name,at: [490,left_sozai_height+2], width: 210, height: 20,size:10, valign: :center)
            text_box("<font size='10'>#{product.sell_price}</font> 円",at: [722,left_sozai_height-5], width: 350, height: 40,size:8,inline_format: true)
            text_box("税込",at: [755,left_sozai_height], width: 350, height: 40,size:6)
            text_box("<font size='8'>#{product.tax_including_sell_price}</font> 円",at: [755,left_sozai_height-8], width: 350, height: 40,size:6,inline_format: true)
          end
          left_sozai_height -= 32
        end
      end
    end
    # left_sozai_height = left_sozai_height - 10
    # text_box("<font size='14'>べじはんのお弁当 Daily Bento</font>　- 主菜の内容は裏面にございます -",
    #    inline_format: true,color:'ffffff',at: [395,left_sozai_height], width: 400, height: 40,size:8)

    # self.line_width = 2
    # line [395, left_sozai_height-20], [menu_x + 375, left_sozai_height-20]
    # stroke_color 'd8d8d8'
    # stroke
    # self.line_width = 1
    
    # left_sozai_height = left_sozai_height - 24
    # text_box("お\n肉",size:7,at: [397,left_sozai_height-11])
    # bounding_box([440, left_sozai_height-9], width: 35, height: 18) do
    #   stroke_bounds
    # end
    # text_box("お\n魚",size:7,at: [442,left_sozai_height-11])
    # bounding_box([395, left_sozai_height-9], width: 35, height: 18) do
    #   stroke_bounds
    # end
    # text_box("ナシ・ 大",size:7,at: [397,left_sozai_height-30])
    # text_box("ナシ・ 大",size:7,at: [442,left_sozai_height-30])


    # text_box("<font size='16'>松</font>　- 主菜、副菜３種、グリル野菜、週替りポタージュ -",at: [490,left_sozai_height-8], width: 320, height: 40,size:9,inline_format: true)
    # text_box("<font size='10'>890〜990</font> 円",at: [640,left_sozai_height-28], width: 350, height: 40,size:8,inline_format: true)
    # text_box("（税込 961〜1,069円）",at: [700,left_sozai_height-30], width: 350, height: 40,size:8)


    # down_height = 35
    # left_sozai_height = left_sozai_height - down_height
    # text_box("お\n肉",size:7,at: [397,left_sozai_height-11])
    # bounding_box([440, left_sozai_height-9], width: 35, height: 18) do
    #   stroke_bounds
    # end
    # text_box("お\n魚",size:7,at: [442,left_sozai_height-11])
    # bounding_box([395, left_sozai_height-9], width: 35, height: 18) do
    #   stroke_bounds
    # end
    # text_box("ナシ・ 大",size:7,at: [397,left_sozai_height-30])
    # text_box("ナシ・ 大",size:7,at: [442,left_sozai_height-30])


    # text_box("<font size='16'>竹</font>　- 主菜、副菜３種、グリル野菜 -",at: [490,left_sozai_height-8], width: 320, height: 40,size:9,inline_format: true)
    # text_box("<font size='10'>790〜890</font> 円",at: [640,left_sozai_height-28], width: 350, height: 40,size:8,inline_format: true)
    # text_box("（税込 853〜961円）",at: [700,left_sozai_height-30], width: 350, height: 40,size:8)
    

    # down_height = 35
    # left_sozai_height = left_sozai_height - down_height
    # text_box("お\n肉",size:7,at: [397,left_sozai_height-11])
    # bounding_box([440, left_sozai_height-9], width: 35, height: 18) do
    #   stroke_bounds
    # end
    # text_box("お\n魚",size:7,at: [442,left_sozai_height-11])
    # bounding_box([395, left_sozai_height-9], width: 35, height: 18) do
    #   stroke_bounds
    # end
    # text_box("ナシ・ 大",size:7,at: [397,left_sozai_height-30])
    # text_box("ナシ・ 大",size:7,at: [442,left_sozai_height-30])


    # text_box("<font size='16'>梅</font>　- 主菜、副菜２種、グリル野菜 -",at: [490,left_sozai_height-8], width: 320, height: 40,size:9,inline_format: true)
    # text_box("<font size='10'>690〜790</font> 円",at: [640,left_sozai_height-28], width: 350, height: 40,size:8,inline_format: true)
    # text_box("（税込 745〜853円）",at: [700,left_sozai_height-30], width: 350, height: 40,size:8)

    # down_height = 32
    # left_sozai_height = left_sozai_height - down_height

    # text_box("お弁当は、ご飯なし（おかずのみ）の場合は商品価格より108円引きでご提供しております。",at: [445,left_sozai_height-20], width: 350, height: 40,size:8)

    
    left_sozai_height = left_sozai_height - 10

    [
      [[22,22],"<font size='14'>スイーツ Sweets</font>　- 手作りした焼き菓子や生菓子を週替りで -"]
    ].each_with_index do |paper_menu_numbers,index|
      menu_x = 395 if index == 3
      text_box(paper_menu_numbers[1],
         inline_format: true,color:'ffffff',at: [menu_x,left_sozai_height], width: 400, height: 40,size:8)
      self.line_width = 2
      line [menu_x, left_sozai_height-20], [menu_x + 380, left_sozai_height-20]
      stroke_color 'd8d8d8'
      stroke
      self.line_width = 1
      left_sozai_height = left_sozai_height - 28

      paper_menu_numbers[0].each_with_index do |i,ii|
        if i == 22
          if ii == 0
            dmd = daily_menu_details[i]
          else
            dmd = next_daily_menu.daily_menu_details.find_by(paper_menu_number:22)
          end
        else
          dmd = daily_menu_details[i]
        end
        if dmd.present?
          product = dmd.product
          if product.smaregi_code.present?
            barcode = Barby::Code128.new product.smaregi_code
            barcode_blob = Barby::PngOutputter.new(barcode).to_png
            barcode_io = StringIO.new(barcode_blob)
            barcode_io.rewind
          end
          image barcode_io, at: [390,left_sozai_height+2], width: 50,height:25 if product.smaregi_code.present?
          bounding_box([445, left_sozai_height-2], width: 26, height: 16) do
            stroke_bounds
          end
          if product.warm_flag == true
            fill_color '000000'
            text_box("●",at: [475,left_sozai_height-4], width: 350, height: 40,size:12)
          end
          fill_color '000000'
          text_box(product.food_label_name,at: [490,left_sozai_height+2], width: 210, height: 20,size:10, valign: :center)
          text_box("<font size='10'>#{product.sell_price}</font> 円",at: [722,left_sozai_height-5], width: 350, height: 40,size:8,inline_format: true)
          text_box("税込",at: [755,left_sozai_height], width: 350, height: 40,size:6)
          text_box("<font size='8'>#{product.tax_including_sell_price}</font> 円",at: [755,left_sozai_height-8], width: 350, height: 40,size:6,inline_format: true)
          left_sozai_height -= 28
        end
      end
    end



    # left_sozai_height -= down_height


    # bounding_box([395, left_sozai_height], width: 26, height: 16) do
    #   stroke_bounds
    # end
    # line [420, left_sozai_height-20], [500, left_sozai_height-20]
    # stroke_color 'd8d8d8'
    # stroke

    # bounding_box([535, left_sozai_height], width: 26, height: 16) do
    #   stroke_bounds
    # end
    # line [560, left_sozai_height-20], [640, left_sozai_height-20]
    # stroke_color 'd8d8d8'
    # stroke

    # bounding_box([665, left_sozai_height], width: 26, height: 16) do
    #   stroke_bounds
    # end
    # line [690, left_sozai_height-20], [770, left_sozai_height-20]
    # stroke_color 'd8d8d8'
    # stroke


    left_sozai_height = 25
    # bounding_box([40, left_sozai_height-10], width: 26, height: 12) do
    #   stroke_color 'd8d8d8'
    #   stroke_bounds
    # end
    # text_box("ドレッシング",size:9,at: [85,left_sozai_height-10])
    # text_box("<font size='10'>100</font> 円　108円",at: [315,left_sozai_height-8],size:8,inline_format: true)
    # stroke do
    #   stroke_color 'd8d8d8'
    #   rounded_rectangle [395, left_sozai_height], 80, 20, 2
    #   text_box("　合計数：",size:8,at: [395,left_sozai_height-7])
    # end
    stroke do
      fill_color '000000'
      text_box("●",size:7,at: [490,left_sozai_height-10])
      fill_color '000000'
      text_box(" の付いている商品は、電子レンジ 500Wで1分程を目安で温めてお召し上がり下さい",size:7,at: [500,left_sozai_height-10])
    end

  end


  def ura_new(bento_menus,from,to)
    # stroke do
    #   fill_color '000000'
    #   fill_rounded_rectangle [-10,530], 440, 40, 4
    #   fill_color 'ffffff'
    #   # text_box("#{from.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[from.wday]})")}〜 #{to.strftime("%-m月%-d日(#{%w(日 月 火 水 木 金 土)[to.wday]})")}",inline_format: true,color:'ffffff',at: [-10,520],align: :center, width: 370, height: 40)
    #   # text_box("日替りお弁当",at: [-10,520], width: 440, height: 40,align: :center,size:20)
    # end
    fill_color '000000'
    text_box("松",at: [43,530], width: 100, height: 40,size:12)
    text_box("主菜、副菜３種、グリル野菜、週替りポタージュ",at: [23,515], width: 80, height: 40,size:6)
    text_box("竹",at: [134,530], width: 100, height: 40,size:12)
    text_box("主菜、副菜３種、グリル野菜",at: [114,515], width: 80, height: 40,size:6)

    text_box("梅",at: [225,530], width: 100, height: 40,size:12)
    text_box("主菜、副菜２種、グリル野菜",at: [205,515], width: 80, height: 40,size:6)

    text_box("お弁当の主菜",at: [300,525], width: 100, height: 40,size:12)

    stroke do
      line [105, 530], [105, -15]
      line [195, 530], [195, -15]
      line [286, 530], [286, -15]
    end


    fill_color "2626ff"
    height = 470
    (from..to).to_a.each do |date|
      bento_height = height +20
      string_date = date.strftime("%-m/%-d\n(#{%w(日 月 火 水 木 金 土)[date.wday]})")
      fill_color "000000"
      text_box(string_date,at: [-17,height+6], width: 45, height: 180,size:9,align: :center,leading:4)
      if bento_menus[date][24].present?
        product_a = bento_menus[date][24]
        if product_a.smaregi_code.present?
          barcode = Barby::Code128.new product_a.smaregi_code
          barcode_blob = Barby::PngOutputter.new(barcode).to_png
          barcode_io = StringIO.new(barcode_blob)
          barcode_io.rewind
        end
        image barcode_io, at: [23,bento_height+4], width: 50,height:20 if product_a.smaregi_code.present?
        product_b = bento_menus[date][26]
        if product_b.smaregi_code.present?
          barcode = Barby::Code128.new product_b.smaregi_code
          barcode_blob = Barby::PngOutputter.new(barcode).to_png
          barcode_io = StringIO.new(barcode_blob)
          barcode_io.rewind
        end
        image barcode_io, at: [111,bento_height+4], width: 50,height:20 if product_b.smaregi_code.present?
        product_c = bento_menus[date][28]
        if product_c.smaregi_code.present?
          barcode = Barby::Code128.new product_c.smaregi_code
          barcode_blob = Barby::PngOutputter.new(barcode).to_png
          barcode_io = StringIO.new(barcode_blob)
          barcode_io.rewind
        end
        image barcode_io, at: [199,bento_height+4], width: 50,height:20 if product_c.smaregi_code.present?


        stroke_color 'd8d8d8'
        bounding_box([76, bento_height+2], width: 20, height: 16) do
          stroke_bounds
        end
        text_box("#{product_a.sell_price}円（#{product_a.tax_including_sell_price}円）",at: [26,bento_height-16], width: 100, height: 40,size:7)
        bounding_box([165, bento_height+2], width: 20, height: 16) do
          stroke_bounds
        end
        text_box("#{product_b.sell_price}円（#{product_b.tax_including_sell_price}円）",at: [115,bento_height-16], width: 100, height: 40,size:7)
        bounding_box([254, bento_height+2], width: 20, height: 16) do
          stroke_bounds
        end
        text_box("#{product_c.sell_price}円（#{product_c.tax_including_sell_price}円）",at: [204,bento_height-16], width: 100, height: 40,size:7)
        text_box(product_b.food_label_name,at: [300,bento_height+2], width: 160, height: 20,size:9, valign: :center)
        bento_height -= 38

        product_a = bento_menus[date][25]
        if product_a.smaregi_code.present?
          barcode = Barby::Code128.new product_a.smaregi_code
          barcode_blob = Barby::PngOutputter.new(barcode).to_png
          barcode_io = StringIO.new(barcode_blob)
          barcode_io.rewind
        end
        image barcode_io, at: [23,bento_height+6], width: 50,height:20 if product_a.smaregi_code.present?
        product_b = bento_menus[date][27]
        if product_b.smaregi_code.present?
          barcode = Barby::Code128.new product_b.smaregi_code
          barcode_blob = Barby::PngOutputter.new(barcode).to_png
          barcode_io = StringIO.new(barcode_blob)
          barcode_io.rewind
        end
        image barcode_io, at: [111,bento_height+6], width: 50,height:20 if product_b.smaregi_code.present?

        product_c = bento_menus[date][29]
        if product_c.smaregi_code.present?
          barcode = Barby::Code128.new product_c.smaregi_code
          barcode_blob = Barby::PngOutputter.new(barcode).to_png
          barcode_io = StringIO.new(barcode_blob)
          barcode_io.rewind
        end
        image barcode_io, at: [199,bento_height+6], width: 50,height:20 if product_c.smaregi_code.present?

        stroke_color 'd8d8d8'
        text_box("#{product_a.sell_price}円（#{product_a.tax_including_sell_price}円）",at: [26,bento_height-16], width: 100, height: 40,size:7)
        bounding_box([76, bento_height+4], width: 20, height: 16) do
          stroke_bounds
        end
        text_box("#{product_b.sell_price}円（#{product_b.tax_including_sell_price}円）",at: [115,bento_height-16], width: 100, height: 40,size:7)
        bounding_box([165, bento_height+4], width: 20, height: 16) do
          stroke_bounds
        end
        text_box("#{product_c.sell_price}円（#{product_c.tax_including_sell_price}円）",at: [204,bento_height-16], width: 100, height: 40,size:7)
        bounding_box([254, bento_height+4], width: 20, height: 16) do
          stroke_bounds
        end
        text_box(product_b.food_label_name,at: [300,bento_height+4], width: 160, height: 20,size:9, valign: :center)
        bento_height -= 40

        line [-8, bento_height+86], [440, bento_height+86]
        stroke
        height -= 72
      else
        text_box("定休日",at: [36,bento_height-16], width: 100, height: 40,size:12)
        bento_height -= 78
        line [-8, bento_height+86], [440, bento_height+86]
        stroke
        height -= 72
      end
    end
  end
end
