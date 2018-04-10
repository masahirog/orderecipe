class HyojiPdf < Prawn::Document
  def initialize(product,kigen,allergies,additives)
    shomi_kigen = kigen["(1i)"]+"年"+kigen["(2i)"]+"月"+kigen["(3i)"]+"日"+" "+kigen["(4i)"]+":"+kigen["(5i)"]
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :portrait)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    table_content(product,shomi_kigen,allergies,additives)

  end

  def table_content(product,shomi_kigen,allergies,additives)
    colls = [-20,171.1764706,362.3529412]
    rows = [775,675,575,475,375,275,175,75]
    for coll in colls
      for row in rows
        bounding_box([coll, row], :width => 180, :height => 96) do
          table line_item_rows(product,shomi_kigen,allergies,additives), cell_style: { size: 6 }  do
          cells.padding = [0, 1, 3, 1]
          cells.valign = :center
          cells.align = :center
          cells.height = 8
          row(1).height = 40
          row(0..1).overflow = :shrink_to_fit
          cells.border_width = 0.1
          row(-1).borders = [:bottom,:right]
          row(-2).columns(1).borders = [:right]
          self.column_widths = [35,140]
          end
        end
      end
    end
  end
  def line_item_rows(product,shomi_kigen,allergies,additives)
    #アレルギーの取得
    allergy =""
    u = 1
    allergies.each do |all|
      if u == allergies.length
        allergy = allergy +"#{all}"
      else
        allergy = allergy +"#{all}、"
      end
    end
    data_child = ""
    #原材料名の表示(メニュー名)
    product.menus.each do |pm|
      data_child = data_child +"#{pm.food_label_name}、"  unless pm.category=="容器"
    end
    #食品添加物の取得
    l = additives.length
    i = 1
    additives.each do |add|
      if i == l
        data_child = data_child + "#{add}"
      else
        data_child = data_child + "#{add}、"
      end
      i += 1
    end

    data= [["名前",product.name]]
    data <<["原材料名",data_child]
    data <<["アレルギー",allergy]
    data <<["消費期限",shomi_kigen]
    data <<["保存方法","直射日光及び高温多湿をお避けください"]
    data <<[{:content => "製造者", :rowspan => 2},"株式会社ベントー・ドット・ジェーピー"]
    data <<["東京都中野区東中野1-35-1 はりまビル1階"]
  end
  def sen
    stroke_axis
  end
end
