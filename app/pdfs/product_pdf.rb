class ProductPdf < Prawn::Document
  def initialize(params,product,menus)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"

    num = params[:volume][:num]
    product = product
    menus = menus
    header_table(product,num)
    table_content(menus)
    table_right(menus,num)
  end


  def header_table(product,num)
    bounding_box([50, 525], :width => 500) do
      data = [["お弁当名","製造数","調理カテゴリ","原価"],
              ["#{product.name}","#{num}人分","#{product.cook_category}","#{product.cost_price} 円"]]
      table data, cell_style: { size: 9 } do
      cells.padding = 2

      row(0).borders = [:bottom]
      columns(0..2).borders = [:right]
      row(0).columns(0..2).borders = [:bottom, :right]
      row(1).columns(3).borders = [:left,:top]
      cells.border_width = 0.2
      cells.height = 14
      self.header = true
      self.column_widths = [200,100,100,100]
      end
    end
  end

  def table_content(menus)
    bounding_box([0, 490], :width => 600) do
    # tableメソッドは2次元配列を引数(line_item_rows)にとり、それをテーブルとして表示する
    # ブロック(do...end)内でテーブルの書式の設定をしている
      table line_item_rows(menus), cell_style: { size: 9 } do
      cells.padding = 2
      cells.borders = [:bottom] # 表示するボーダーの向き(top, bottom, right, leftがある)
      cells.border_width = 0.2
      cells.height = 14


      row(0).border_width = 1
      self.header = true
      self.column_widths = [160,40,160,160,70]
      end
    end
  end
  def line_item_rows(menus)
    data= [["メニュー名","カテゴリ","調理メモ","食材・資材","1人分"]]
    menus.each do |menu|
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


  def table_right(menus,num)
    bounding_box([600, 490], :width => 100) do
      table right_item_rows(menus,num), cell_style: { size: 9,align: :right } do
      cells.padding = 2
      cells.borders = [:bottom,]
      cells.border_width = 0.2
      cells.height = 14
      row(0).border_width = 1
      self.header     = true
      self.column_widths = [100]
      end
    end
  end
  def right_item_rows(menus,num)
    data= [["#{num}人分"]]
    menus.each do |menu|
      u = menu.materials.length
      menu.menu_materials.each_with_index do |mm,i|
        if i == 0
          data << ["#{((mm.amount_used * num.to_i).round).to_s(:delimited)} #{Material.find(mm.material_id).calculated_unit}"]
        else
          data << ["#{((mm.amount_used * num.to_i).round).to_s(:delimited)} #{Material.find(mm.material_id).calculated_unit}"]
        end
      end
    end
    data
  end

  def sen
    stroke_axis
  end


end
