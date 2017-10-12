class OrderPdf < Prawn::Document
  def initialize(materials_this_vendor,order,order_materials)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(page_size: 'A4')
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    #インスタンス変数
    @order = order
    @materials_this_vendor = materials_this_vendor
    @order_materials = order_materials
    # メソッドを作成。下記に内容あり。
    # content
    # render_table
    # sen

    header
    header_lead
    header_date
    header_adress
    header_hello
    table_content
    table_right
    sen2
  end

  def header
    bounding_box([170, 770], :width => 120, :height => 50) do
      # size 28 で "Order"という文字を表示
      text "発 注 書", size: 24
    end
    # stroke(線)の色を設定し、線を引く
    # stroke_color "eeeeee"
    # stroke_line [0, 680], [530, 680]
  end

  def header_lead
    # bounding_boxで記載箇所を指定して、textメソッドでテキストを記載
    bounding_box([0, 720], :width => 270, :height => 50) do
      font_size 10.5
      text "#{Vendor.find(@materials_this_vendor[0].vendor_id).company_name}　御中", size: 15
    end
  end
  def header_date
    bounding_box([280, 730], :width => 140, :height => 20) do
        font_size 10.5
        text "#{@order.delivery_date.strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[@order.delivery_date.wday]})")} 納品分"
    end
  end
  def header_adress
    bounding_box([260, 690], :width => 160, :height => 50) do
        font_size 8.5
        text "株式会社ベントー・ドット・ジェーピー"
        text "(弁当将軍キッチン)"
        text "〒164-0003 東京都中野区東中野1-35-1"
        text "TEL：03-5937-5431"
    end
  end
  def header_hello
    bounding_box([20, 690], :width => 200, :height => 50) do
        font_size 8.5
        text "いつも大変お世話になっております。"
        text "下記の通り発注致します。"
        text "どうぞよろしくお願い致します。"
    end
  end
  def sen2
    stroke_color "F0F0F0"
    stroke_vertical_line 0, 800, :at => 450
  end

  def table_content
    bounding_box([20, 640], :width => 400, :height => 550) do
    # tableメソッドは2次元配列を引数(line_item_rows)にとり、それをテーブルとして表示する
    # ブロック(do...end)内でテーブルの書式の設定をしている
      table line_item_rows, cell_style: { size: 10 } do
      # 全体設定
      cells.padding = 3          # セルのpadding幅
      cells.borders = [:bottom,] # 表示するボーダーの向き(top, bottom, right, leftがある)
      cells.border_width = 0.5   # ボーダーの太さ
      cells.height = 20
      # 個別設定
      # row(0) は0行目、row(-1) は最後の行を表す
      row(0).border_width = 1.5
      #一番下の行
      # row(-1).background_color = "f0ad4e"
      # row(-1).borders = []

      self.header     = true  # 1行目をヘッダーとするか否か
      self.row_colors = ['FBFAFA', 'ffffff'] # 列の色
      self.column_widths = [300, 60,40] # 列の幅
      end
      text "　"
      text "＜備考＞", size: 11
    end
  end
  # テーブルに表示するデータを作成(2次元配列)
  def line_item_rows
    # テーブルのヘッダ部
    data= [["品名・品番","数量","単位"]]
    @materials_this_vendor.each do |mtv|
      s_data = []
      data << ["#{mtv.order_name}","",""]
    end

     l = @materials_this_vendor.length
     if l < 10
       u = 15 - l
     elsif l < 20
       u = 25 - l
     else
       u = 5
     end
     data += [["","",""]] * u
  end

  def table_right
    bounding_box([455, 640], :width => 100, :height => 550) do
    # tableメソッドは2次元配列を引数(line_item_rows)にとり、それをテーブルとして表示する
    # ブロック(do...end)内でテーブルの書式の設定をしている
      table line_item_right_rows, cell_style: { size: 7.5 } do
      # 全体設定
      cells.padding = 3          # セルのpadding幅
      cells.borders = [:bottom,] # 表示するボーダーの向き(top, bottom, right, leftがある)
      cells.border_width = 0.5   # ボーダーの太さ
      cells.height = 20
      # 個別設定
      # row(0) は0行目、row(-1) は最後の行を表す
      row(0).border_width = 1.5
      #一番下の行
      # row(-1).background_color = "f0ad4e"
      # row(-1).borders = []

      self.header     = true  # 1行目をヘッダーとするか否か
      self.row_colors = ['FBFAFA', 'ffffff'] # 列の色
      self.column_widths = [60] # 列の幅
      end
    end
  end

  def line_item_right_rows
    # テーブルのヘッダ部
    data= [["計算欄"]]

    @materials_this_vendor.each do |mtv|
        data << ["#{@order_materials.find_by(material_id:mtv.id).order_quantity}" "#{mtv.calculated_unit}"]
    end

     l = @materials_this_vendor.length
     if l < 10
       u = 15 - l
     elsif l < 20
       u = 25 - l
     else
       u = 5
     end
     data += [[""]] * u
  end


  # def sen
  #   stroke_axis
  # end


end
