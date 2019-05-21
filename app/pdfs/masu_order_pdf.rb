class MasuOrderPdf < Prawn::Document
  def initialize(products_num_h,date,mochiba)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"

    menus = []
    products_arr = []
    products_num_h.each do |prnm|
      product = Product.find(prnm[0])
      num = prnm[1]
      products_arr << [product.name,prnm[1]]
      product.menus.each do |menu|
        menus << [menu.id,num]
      end
    end
    hash = {}
    menus.each do |menu|
      if hash[menu[0]]
        hash[menu[0]] += menu[1]
      else
        hash[menu[0]] = menu[1]
      end
    end
    arr = []
    products_arr.each do |product_num|
      arr << ["#{product_num[0]}","#{product_num[1]} 食"]
    end

    if mochiba == 'choriba'
      text "調理場  #{date}"
      move_down 2
      table(arr, :column_widths => [500, 100], :cell_style =>{:border_width =>0.1,size:9 })
      move_down 1
      table_content(hash,'調理場')
    elsif mochiba == 'kiriba'
      text "切出し  #{date}"
      move_down 2
      table(arr, :column_widths => [500, 100], :cell_style =>{:border_width =>0.1,size:9 })
      move_down 1
      table_content(hash,'切出し')
    else
      text "調理場  #{date}"
      move_down 2
      arr = []
      products_arr.each do |product_num|
        arr << ["#{product_num[0]}","#{product_num[1]} 食"]
      end
      table(arr, :column_widths => [500, 100], :cell_style =>{:border_width =>0.1,size:9 })
      move_down 1
      table_content(hash,'調理場')

      start_new_page

      text "切出し  #{date}"
      move_down 2
      table(arr, :column_widths => [500, 100], :cell_style =>{:border_width =>0.1,size:9 })
      move_down 1
      table_content(hash,'切出し')

    end
  end

  def table_content(hash,mochiba)
      hash.each do |menu_num|
        menu = Menu.find(menu_num[0])
        unless menu.category == '容器'
          if mochiba == '調理場'
            post1 = '調理場'
            post2 = '切出/調理'
          else
            post1 = '切出し'
            post2 = '切出/スチコン'
            post3 = '切出/調理'
          end
          if menu.menu_materials.map{|mm|mm.post}.include?(post1) || menu.menu_materials.map{|mm|mm.post}.include?(post2) || menu.menu_materials.map{|mm|mm.post}.include?(post3)
            num = menu_num[1]
            move_down 10
            table line_item_rows(menu,num) do
              cells.padding = 3
              cells.size = 9
              cells.borders = [:bottom]
              cells.border_width = 0.1

              column(4).align = :right
              column(5).size = 9
              column(5).align = :center
              column(5).text_color = '808080'
              row(0).border_color = "000000"
              row(0).background_color = 'dcdcdc'
              row(0).text_color = "000000"
              column(0).row(0).borders = [:left,:top,:bottom]
              column(1..-2).row(0).borders = [:top,:bottom]
              column(-2).row(0).borders = [:top,:bottom,:right]
              column(-1).row(1..-1).borders = [:right,:bottom]
              column(0).row(1).borders = [:left,:bottom]
              column(0).row(1).borders = [:left,:bottom]
              column(1..2).row(1).borders = [:bottom]
              # column(4).background_color = 'dcdcdc'
              column(4).padding = [3,8,3,3]
              row(0).size = 9
              self.header = true
              self.column_widths = [100,120,120,110,70,30,60,200]
              grayout = []
              menuline = []
              values = cells.columns(6).rows(1..-1)
              values.each do |cell|
                if mochiba == "調理場"
                  grayout << cell.row unless cell.content == mochiba || cell.content == "切出/調理"
                else
                  grayout << cell.row unless cell.content == mochiba || cell.content == "切出/調理" || cell.content == "切出/スチコン"
                end
              end
              grayout.map{|num|row(num).column(3..-1).background_color = "dcdcdc"}
              menu_values = cells.columns(0).rows(1..-1)
              menu_values.each do |cell|
                menuline << cell.row if cell.content.present?
              end
            end
          end
        end
      end
  end
  def line_item_rows(menu,num)
    data = [["メニュー名","調理メモ","盛付メモ","食材・資材","#{num}人分",'✓',{:content => "仕込み内容", :colspan => 2}]]
    u = menu.materials.length
    recipe_mozi = menu.recipe.length
    if recipe_mozi<50
      recipe_size = 10
    elsif recipe_mozi<100
      recipe_size = 9
    elsif recipe_mozi<150
      recipe_size = 8
    else
      recipe_size = 7
    end
    menu.menu_materials.each_with_index do |mm,i|
      if mm.post.present?
        check = "□"
      else
        check = ""
      end
      if i == 0
        data << [{content: "#{menu.name}", rowspan: u},
          {content: "#{menu.recipe}", rowspan: u, size: recipe_size},{content: "#{menu.serving_memo}", rowspan: u},"#{mm.material.name}",
          "#{((mm.amount_used * num.to_i).round).to_s(:delimited)} #{mm.material.calculated_unit}",check,mm.post,mm.preparation]
      else
        data << [mm.material.name,{content:"#{((mm.amount_used * num.to_i).round).to_s(:delimited)} #{mm.material.calculated_unit}"},
          check,mm.post,mm.preparation]
      end
    end
    data
  end
  def sen
    stroke_axis
  end
end
