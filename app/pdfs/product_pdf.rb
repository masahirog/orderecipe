class ProductPdf < Prawn::Document
  def initialize(params,product,menus)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    #インスタンス変数
    @num = params[:volume][:num]
    @product = product
    @menus = menus
    # メソッドを作成。下記に内容あり。
    # content
    # render_table

    header
    header_lead
    table_content
    table_right
    preparation_cut_title
    preparation_cut
    preparation_cook_title
    preparation_cook
    preparation_duble_title
    preparation_duble
  end


  def header_lead
    bounding_box([75, 520], :width => 350, :height => 50) do
      text "#{@product.name}", size: 9,leading: 3
      text "#{@product.cook_category}", size: 9,leading: 3
      text "#{@product.cost_price} 円", size: 9,leading: 3
    end
  end
  def header
    bounding_box([0, 520], :width => 60, :height => 50) do
      text "お弁当名:", size: 9,leading: 3,align: :right
      text "調理カテゴリ:", size: 9,leading: 3,align: :right
      text "原価:", size: 9,leading: 3,align: :right
    end
  end
  def image
  end


  def table_content
    bounding_box([20, 480], :width => 380, :height => 400) do
    # tableメソッドは2次元配列を引数(line_item_rows)にとり、それをテーブルとして表示する
    # ブロック(do...end)内でテーブルの書式の設定をしている
      table line_item_rows, cell_style: { size: 7 } do
      # 全体設定

      cells.padding = 2         # セルのpadding幅
      cells.borders = [:bottom,] # 表示するボーダーの向き(top, bottom, right, leftがある)
      cells.border_width = 0.5   # ボーダーの太さ
      cells.height = 12
      # 個別設定
      # row(0) は0行目、row(-1) は最後の行を表す
      row(0).border_width = 1
      #一番下の行
      # row(-1).background_color = "f0ad4e"
      # row(-1).borders = []

      self.header     = true  # 1行目をヘッダーとするか否か
      # self.row_colors = ['FBFAFA', 'ffffff'] # 列の色
      self.column_widths = [80,40,110,100,50] # 列の幅
      end
    end
  end
  # テーブルに表示するデータを作成(2次元配列)
  def line_item_rows
    # テーブルのヘッダ部
    data= [["メニュー名","カテゴリ","調理メモ","食材・資材","使用量"]]
    @menus.each do |menu|
      u = menu.materials.length
      s_data = []
      menu.menu_materials.each_with_index do |mm,i|
        if i == 0
          data << [{:content => "#{menu.name}", :rowspan => u},{:content => "#{menu.category}", :rowspan => u},
            {:content => "#{menu.recipe}", :rowspan => u},"#{Material.find(mm.material_id).name}",
            "#{mm.amount_used} #{Material.find(mm.material_id).calculated_unit}"]
        else
          data << ["#{Material.find(mm.material_id).name}","#{mm.amount_used} #{Material.find(mm.material_id).calculated_unit}"]
        end
      end
    end
    data
  end


  def table_right
    bounding_box([405, 480], :width => 60, :height => 400) do
    # tableメソッドは2次元配列を引数(line_item_rows)にとり、それをテーブルとして表示する
    # ブロック(do...end)内でテーブルの書式の設定をしている
      table right_item_rows, cell_style: { size: 7,align: :right } do
      # 全体設定

      cells.padding = 2         # セルのpadding幅
      cells.borders = [:bottom,] # 表示するボーダーの向き(top, bottom, right, leftがある)
      cells.border_width = 0.5   # ボーダーの太さ
      cells.height = 12
      # 個別設定
      # row(0) は0行目、row(-1) は最後の行を表す
      row(0).border_width = 1
      #一番下の行
      # row(-1).background_color = "f0ad4e"
      # row(-1).borders = []

      self.header     = true  # 1行目をヘッダーとするか否か
      self.row_colors = ['FFFEA9'] # 列の色
      self.column_widths = [60] # 列の幅
      end
    end
  end
  # テーブルに表示するデータを作成(2次元配列)
  def right_item_rows
    # テーブルのヘッダ部
    data= [["#{@num}人分"]]
    @menus.each do |menu|
      u = menu.materials.length
      s_data = []
      menu.menu_materials.each_with_index do |mm,i|
        if i == 0
          data << ["#{((mm.amount_used * @num.to_i).round).to_s(:delimited)} #{Material.find(mm.material_id).calculated_unit}"]
        else
          data << ["#{((mm.amount_used * @num.to_i).round).to_s(:delimited)} #{Material.find(mm.material_id).calculated_unit}"]
        end
      end
    end
    data
  end

  def preparation_cut_title
    bounding_box([500, 515], :width => 250, :height => 20) do
      text "切り出し"
    end
  end

  def preparation_cut
    bounding_box([500, 500], :width => 250, :height => 145) do
      stroke_bounds
      pad(6){
      @menus.each do |menu|
        menu.menu_materials.each do |mm|
          if mm.post == "切り出し"
          text "　＜#{mm.material.name}＞ #{(mm.amount_used.round * @num.to_i).to_s(:delimited)} #{mm.material.calculated_unit}を#{mm.preparation}", size: 8,leading: 5
          end
        end
      end}
    end
  end

  def preparation_cook_title
    bounding_box([500, 345], :width => 250, :height => 20) do
      text "調理場"
    end
  end

  def preparation_cook
    bounding_box([500,330], :width => 250, :height => 145) do
      stroke_bounds
      pad(6){
      @menus.each do |menu|
        menu.menu_materials.each do |mm|
          if mm.post == "調理場"
            text "　＜#{mm.material.name}＞ #{(mm.amount_used.round * @num.to_i).to_s(:delimited)} #{mm.material.calculated_unit}を#{mm.preparation}", size: 8,leading: 5
          end
        end
      end}
    end
  end

  def preparation_duble_title
    bounding_box([500, 175], :width => 250, :height => 20) do
      text "切出/調理場"
    end
  end

  def preparation_duble
    bounding_box([500,160], :width => 250, :height => 145) do
      stroke_bounds
      pad(6){
      @menus.each do |menu|
        menu.menu_materials.each do |mm|
          if mm.post == "切出/調理場"
            text "　＜#{mm.material.name}＞ #{(mm.amount_used.round * @num.to_i).to_s(:delimited)} #{mm.material.calculated_unit}を#{mm.preparation}", size: 8,leading: 5
          end
        end
      end}
    end
  end

  def sen
    stroke_axis
  end


end
