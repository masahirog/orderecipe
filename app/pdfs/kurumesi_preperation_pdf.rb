class KurumesiPreperationPdf < Prawn::Document
  def initialize(bentos_num_h,date,mochiba)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:15
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    menus = []
    products_arr = []
    products = Product.includes(:brand,:menus,product_menus:[:menu]).where(id:bentos_num_h.keys)
    products.each do |product|
      num = bentos_num_h[product.id]
      products_arr << [product.brand.name,product.name,num]
      product.menus.each do |menu|
        menus << [menu.base_menu_id,menu.id,num]
      end
    end
    hash = {}
    menus.each do |menu|
      if hash[menu[0]]
        if hash[menu[0]][menu[1]]
          hash[menu[0]][menu[1]] += menu[2]
        else
          hash[menu[0]][menu[1]] = menu[2]
        end
      else
        hash[menu[0]] = {menu[1]=>menu[2]}
      end
    end
    arr = []
    products_arr.each do |product_num|
      arr << ["#{product_num[0]}","#{product_num[1]}","#{product_num[2]} 食"]
    end
    if mochiba == 'choriba'
      text "調理場  #{date}"
      move_down 2
      table(arr, :column_widths => [150,500, 100], :cell_style =>{:border_width =>0.1,size:9 },:row_colors => ["f5f5f5", "FFFFFF"])
      move_down 1
      table_content(hash,'調理場')
    elsif mochiba == 'kiriba'
      text "切出し  #{date}"
      move_down 2
      table(arr, :column_widths => [150,500, 100], :cell_style =>{:border_width =>0.1,size:9 },:row_colors => ["f5f5f5", "FFFFFF"])
      move_down 1
      table_content(hash,'切出し')
    elsif mochiba == 'tare'
      text "タレ  #{date}"
      move_down 2
      table(arr, :column_widths => [150,500, 100], :cell_style =>{:border_width =>0.1,size:9 },:row_colors => ["f5f5f5", "FFFFFF"])
      move_down 1
      table_content(hash,'タレ')
    else
      text "調理場  #{date}"
      move_down 2
      table(arr, :column_widths => [150,500, 100], :cell_style =>{:border_width =>0.1,size:9 },:row_colors => ["f5f5f5", "FFFFFF"])
      move_down 1
      table_content(hash,'調理場')

      start_new_page

      text "切出し  #{date}"
      move_down 2
      table(arr, :column_widths => [150,500, 100], :cell_style =>{:border_width =>0.1,size:9 },:row_colors => ["f5f5f5", "FFFFFF"])
      move_down 1
      table_content(hash,'切出し')
    end
    page_count.times do |i|
      go_to_page(i+1)
      bounding_box([bounds.right-50, bounds.bottom + 25], :width => 50) {
        text "#{i+1} / #{page_count}"
      }
    end
  end

  def table_content(hash,mochiba)
    base_menu_ids = hash.keys
    base_menus = Menu.includes(:menu_materials).where(id:base_menu_ids).order("cook_on_the_day DESC")
    merged_hash = hash.values.inject do |h1, h2|
      h1.merge(h2) do |key, oldval, newval|
        oldval + newval
      end
    end
    menus = Menu.includes(menu_materials:[:material]).where(id:merged_hash.keys)
    menu_materials = MenuMaterial.includes(:material).where(menu_id:merged_hash.keys).map{|mm|[mm.base_menu_material_id,mm]}.to_h
    same_base_menu_hash = {}
    menus.each do |menu|
      if same_base_menu_hash[menu.base_menu_id].present?
        same_base_menu_hash[menu.base_menu_id] << menu
      else
        same_base_menu_hash[menu.base_menu_id] = [menu]
      end
    end
    base_menus.each do |bm|
      menu_name_arr = []
      base_menu = bm
      unless base_menu.category == '容器'
        if mochiba == '調理場'
          post1 = '調理場'
          post2 = '切出/調理'
        else
          post1 = '切出し'
          post2 = '切出/スチ'
          post3 = '切出/調理'
        end
        if base_menu.menu_materials.map{|mm|mm.post}.include?(post1) || base_menu.menu_materials.map{|mm|mm.post}.include?(post2) || base_menu.menu_materials.map{|mm|mm.post}.include?(post3)
          menus = same_base_menu_hash[base_menu.id]
          arr_kari_a = {}
          menus.each do |menu|
            num = merged_hash[menu.id]
            if menu.base_menu_id == menu.id
              menu_name_arr << "★ #{menu.name}（#{num}食）"
            else
              menu_name_arr << "#{menu.name}（#{num}食）"
            end
            menu.menu_materials.each do |mm|
              if arr_kari_a[mm.base_menu_material_id].present?
                arr_kari_a[mm.base_menu_material_id][1] += (mm.amount_used * num)
              else
                arr_kari_a[mm.base_menu_material_id] = [menu_materials[mm.base_menu_material_id],(mm.amount_used * num)]
              end
            end
          end
          menu_name = menu_name_arr.join("\n\n")
          # arr_hon = arr_kari.transpose.map{|a| a.inject(:+).round(1) }
          move_down 10
          table line_item_rows(base_menu,arr_kari_a,menu_name) do
            # cells.padding = 3
            cells.leading = 2
            cells.size = 9
            cells.borders = [:bottom]
            cells.border_width = 0.1
            column(3).align = :right
            column(4).align = :center
            column(4).text_color = '808080'
            row(0).border_color = "000000"
            row(0).background_color = 'dcdcdc'
            row(0).text_color = "000000"
            column(0).row(0).borders = [:left,:top,:bottom]
            column(1..-2).row(0).borders = [:top,:bottom]
            column(-2).row(0).borders = [:top,:bottom,:right]
            column(-1).row(1..-1).borders = [:right,:bottom]
            column(0).row(1).borders = [:left,:bottom]
            column(0).row(1).borders = [:left,:bottom]
            column(1).row(1).borders = [:bottom]
            # column(4).background_color = 'dcdcdc'
            column(3).padding = [3,8,3,3]
            row(0).size = 9
            self.header = true
            self.column_widths = [140,200,110,70,30,60,200]
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
          end
        end
      end
    end
  end
  def line_item_rows(menu,arr_kari_a,menu_name)
    data = [["メニュー名","調理メモ","食材・資材","分量",'✓',{:content => "仕込み内容", :colspan => 2}]]
    u = menu.menu_materials.length
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

    arr_kari_a.each_with_index do |hash,i|
      if hash[1][1] == hash[1][1].to_i
        amount = hash[1][1].to_i
      else
        amount = hash[1][1].round(1)
      end
      mm = hash[1][0]
      if mm.post.present?
        check = "□"
      else
        check = ""
      end
      if i == 0
        memo = "【 前日 】\n#{menu.cook_the_day_before}\n―・―・―・―・―・―・―・―・―・―\n【 当日 】\n#{menu.cook_on_the_day}"
        data << [{content: "#{menu_name}", rowspan: u},
          {content: memo, rowspan: u, size: cook_the_day_before_size},"#{mm.material.name}",
          "#{amount} #{mm.material.recipe_unit}",check,mm.post,mm.preparation]
      else
        data << [mm.material.name,{content:"#{amount} #{mm.material.recipe_unit}"},
          check,mm.post,mm.preparation]
      end
    end
    data
  end
  def sen
    stroke_axis
  end
end
