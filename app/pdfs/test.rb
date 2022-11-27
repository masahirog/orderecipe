require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

class Test < Prawn::Document
  def initialize(store_daily_menu)
    super(
      page_size: 'A4',
      page_layout: :landscape,
      :top_margin    => 0 )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    left_header(store_daily_menu)
    right_header(store_daily_menu)
    left_table(store_daily_menu)

    right_table_top(store_daily_menu)
    right_middle_tittle(store_daily_menu)
    right_table_bottom(store_daily_menu)
    right_footer(store_daily_menu)
    sen
  end
  # image 'app/assets/images/taberu_stamp.png', at: [440, 630], width: 60
  def left_header(store_daily_menu)
    stroke do
      fill_color '000000'
      fill_rounded_rectangle [-5,535], 370, 75, 4
      fill_color 'ffffff'
      text_box("11月23日（水）〜  11月29日（火）",at: [-5,530], width: 350, height: 40,align: :center)
      text_box("今週の週替りお惣菜",at: [-5,510], width: 350, height: 40,align: :center)
      text_box("毎週水曜日にメニューがすべて入れ替わります",at: [-5,490], width: 350, height: 40,align: :center)
      fill_color 'cc0000'
      fill_rounded_rectangle [-15,545], 50, 50, 25
      fill_color 'ffffff'
      text_box("毎週\n替わる",at: [-7, cursor - 25], width: 40, height: 40,rotate: 20, rotate_around: :center,align: :center)

    end
  end
  def right_header(store_daily_menu)
    stroke do
      stroke_color 50, 100, 0, 0
      fill_and_stroke_rounded_rectangle [395,535], 380, 120, 4
      fill_color '000000'
      text_box("ほろほろに煮込んだ 牛すじ煮込み",at: [400,530], width: 350, height: 40,align: :center)
      text_box("ほろほろになるまで柔らかく煮込んだ牛すじ。味の染みた大きな大根。刻んだ青ねぎをたっぷりかけて。毎日継ぎ足しで煮込み続けています。",at: [400,510], width: 350, height: 40,align: :center)
      text_box("毎週水曜日にメニューがすべて入れ替わります",at: [400,490], width: 350, height: 40,align: :center)
      fill_color '006600'
      fill_rounded_rectangle [385,545], 50, 50, 25
      fill_color 'ffffff'
      text_box("おすすめ\nメニュー",at: [393, cursor - 25], width: 50, height: 40,rotate: 20, rotate_around: :center,align: :center)
    end
  end
  def left_table(store_daily_menu)
    fill_color '000000'
    bounding_box([-10,450], :width => 380) do
      data= []
      store_daily_menu.store_daily_menu_details.each do |sdmd|
        barcode = Barby::Code128.new 417
        barcode_blob = Barby::PngOutputter.new(barcode).to_png
        barcode_io = StringIO.new(barcode_blob)
        barcode_io.rewind
        data << [{:image => barcode_io, :image_height => 20,:image_width => 40},'',sdmd.product.name,"#{sdmd.product.sell_price}円","税込\n#{sdmd.price}円"]
      end
      table data do
        # cells.borders = []
        cells.size = 9
        self.header = true
        self.column_widths = [40,40,220,50,30]
      end
    end
  end

  def right_table_top(store_daily_menu)

  end
  def right_middle_tittle(store_daily_menu)

  end
  def right_table_bottom(store_daily_menu)

  end
  def right_footer(store_daily_menu)

  end

  def sen
    stroke_axis
  end
end
