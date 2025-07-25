class ShogunPreparation < Prawn::Document
  def initialize(params,product,menus)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    num = params[:volume][:num]
    product = product
    menus = menus
    header_table(product,num,'調理場')
    table_content(menus,num,'調理場')
    # stroke_axis
    start_new_page
    header_table(product,num,'切出し')
    table_content(menus,num,'切出し')
  end



  def header_table(product,num,mochiba)
    bounding_box([0, 570], :width => 830) do
      data = [["持ち場","商品名","原価","製造数"],
              [mochiba,"#{product.name}","#{product.cost_price} 円","#{num}人分"]]
      table data, cell_style: { size: 9 } do
      cells.padding = 2
      row(0).background_color = 'dcdcdc'
      row(0).borders = [:bottom]
      columns(0..-1).borders = []
      row(0).columns(0..-1).borders = [:bottom]
      cells.border_width = 0.2
      cells.height = 14
      self.header = true
      self.column_widths = [50,320,100,100,100,100]
      end
    end
  end

  def table_content(menus,num,mochiba)
    bounding_box([0, 540], :width => 820) do
      table line_item_rows(menus,num) do
      cells.padding = 3
      cells.size = 9
      cells.borders = [:bottom]
      cells.border_width = 0.1
      cells.border_color = "a9a9a9"
      column(3).align = :right
      column(4).size = 9
      column(4).align = :center
      column(4).text_color = '808080'
      row(0).border_width = 1
      row(0).border_color = "000000"
      row(0).background_color = 'dcdcdc'
      row(0).text_color = "000000"
      column(3).padding = [3,8,3,3]
      row(0).size = 9
      self.header = true
      self.column_widths = [120,200,150,80,30,50,190]
      grayout = []
      menuline = []
      values = cells.columns(5).rows(1..-1)
      values.each do |cell|
        if mochiba == "調理場"
          grayout << cell.row unless cell.content == mochiba || cell.content == "切出/調理"
        else
          grayout << cell.row unless cell.content == mochiba || cell.content == "切出/調理" || cell.content == "切出/スチ"
        end
      end
      grayout.map{|num|row(num).column(2..-1).background_color = "dcdcdc"}
      menu_values = cells.columns(0).rows(1..-1)
      menu_values.each do |cell|
        menuline << cell.row if cell.content.present?
      end
      menuline.map{|num|row(num).border_width = 0.5,row(num).border_color = '000000',row(num).borders=[:top]}

      end
    end
  end
  def line_item_rows(menus,num)
    data= [["メニュー名","調理メモ","食材・資材","#{num}人分",'✓',{:content => "仕込み内容", :colspan => 2}]]
    menus.each do |menu|
      unless menu.category == '容器'
        u = menu.materials.length
        cook_the_day_before_mozi = menu.cook_the_day_before.length
        if cook_the_day_before_mozi<50
          cook_the_day_before_size = 10
        elsif cook_the_day_before_mozi<100
          cook_the_day_before_size = 9
        elsif cook_the_day_before_mozi<150
          cook_the_day_before_size = 8
        else
          cook_the_day_before_size = 7
        end
        menu.menu_materials.each_with_index do |mm,i|
          if mm.post.present?
            check = "□"
          else
            check = ""
          end
          if i == 0
            data << [{content: "#{menu.name}", rowspan: u},
              {content: "#{menu.cook_the_day_before}", rowspan: u, size: cook_the_day_before_size},"#{mm.material.name}",
              "#{((mm.amount_used * num.to_i).round(1)).to_s(:delimited)} #{mm.material.recipe_unit}",check,mm.post,mm.preparation]
          else
            data << [mm.material.name,{content:"#{((mm.amount_used * num.to_i).round(1)).to_s(:delimited)} #{mm.material.recipe_unit}"},
              check,mm.post,mm.preparation]
          end
        end
      end
    end
    data
  end


  def sen
    stroke_axis
  end


end
