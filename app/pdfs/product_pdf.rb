  class ProductPdf < Prawn::Document
  def initialize(params,product,menus)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"

    @num = params[:volume][:num]
    @product = product
    @menus = menus

    # sen
    header
    header_lead
    table_content
    table_right
    preparation_title("切り出し",450,520)
    table_prepa(prepa_item_rows("切り出し"),450,510)
    prepa_item_rows("切り出し")
    preparation_title("調理場",450,340)
    table_prepa(prepa_item_rows("調理場"),450,330)
    prepa_item_rows("調理場")
    preparation_title("切出/調理場",450,160)
    table_prepa(prepa_item_rows("切出/調理場"),450,150)
    prepa_item_rows("切出/調理場")
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
    bounding_box([0, 480], :width => 370) do
    # tableメソッドは2次元配列を引数(line_item_rows)にとり、それをテーブルとして表示する
    # ブロック(do...end)内でテーブルの書式の設定をしている
      table line_item_rows, cell_style: { size: 7 } do
      cells.padding = 2
      cells.borders = [:bottom] # 表示するボーダーの向き(top, bottom, right, leftがある)
      cells.border_width = 0.2
      cells.height = 13


      row(0).border_width = 1
      self.header = true
      self.column_widths = [80,40,110,100,40]
      end
    end
  end
  def line_item_rows
    data= [["メニュー名","カテゴリ","調理メモ","食材・資材","1人前"]]
    @menus.each do |menu|
      u = menu.materials.length
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
    bounding_box([375, 480], :width => 60) do
      table right_item_rows, cell_style: { size: 9,align: :right } do
      cells.padding = 2
      cells.borders = [:bottom,]
      cells.border_width = 0.2
      cells.height = 13
      row(0).border_width = 1
      self.header     = true
      self.column_widths = [60]
      end
    end
  end
  def right_item_rows
    data= [["#{@num}人分"]]
    @menus.each do |menu|
      u = menu.materials.length
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


  def preparation_title(a,x,y)
    bounding_box([x, y], :width => 250, :height => 10) do
      text a, size: 8
    end
  end

  def table_prepa(b,x,y)
    bounding_box([x, y], :width => 310) do
      table b, cell_style: { size: 7,align: :left } do
        cells.padding = 2
        column(2).align = :right
        column(2).padding = [2,6,2,2]
        column(3).padding = [2,2,2,6]
        cells.border_width = 0.2
        self.column_widths = [20,90,60,140]
      end
    end
  end

  def prepa_item_rows(c)
    data = []
    @menus.each do |menu|
      u = menu.materials.length
      menu.menu_materials.each do |mm|
        if mm.post == c
          data << ["","#{mm.material.name}", "#{(mm.amount_used * @num.to_i).round.to_s(:delimited)} #{mm.material.calculated_unit}",
          "#{mm.preparation}"]
        end
      end
    end
    i = data.length
    if i < 5
      data += [["　","　","　","　"]]*(5)
    elsif i< 10
      data += [["　","　","　","　"]]*(10-i)
    elsif i<15
      data += [["　","　","　","　"]]*(10-i)
    else
      data
    end
  end

  def sen
    stroke_axis
  end


end
