class MaterialPreparation < Prawn::Document
  def initialize(bentos_num_h,date,mochiba,lang)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    menus = []
    menu_materials_arr_cut = []
    menu_materials_arr_cook = []
    products_arr = []
    hash = {}
    arr_hon = []
    bentos_num_h.each do |prnm|
      product = Product.find(prnm[0])
      num = prnm[1]
      products_arr << [product.name,prnm[1]]
      product.menus.each do |menu|
        menus << [menu.base_menu_id,menu.id,num]
      end
    end
    test_hash = {}
    base_menu_hash = {}
    menus.each do |menu|
      if base_menu_hash[menu[0]]
        if base_menu_hash[menu[0]][menu[1]]
          base_menu_hash[menu[0]][menu[1]] += menu[2]
        else
          base_menu_hash[menu[0]][menu[1]] = menu[2]
        end
      else
        base_menu_hash[menu[0]] = {menu[1]=>menu[2]}
      end
    end
    base_menu_hash.each do |bnh|
      bnh[1].each do |menu_num|
        menu = Menu.find(menu_num[0])
        num = menu_num[1]
        menu.menu_materials.includes(:material).order('materials.category').where(:materials => {measurement_flag:true}).each do |mm|
          base_menu_material_id = mm.base_menu_material_id
          if test_hash[base_menu_material_id]
            test_hash[base_menu_material_id][2] =(test_hash[base_menu_material_id][2] + mm.amount_used * num).round(1)
            if lang == "1"
              test_hash[base_menu_material_id][6] += "、#{menu.name}（#{num}）"
            else
              test_hash[base_menu_material_id][6] += "、#{menu.roma_name}（#{num}）"
            end
          else
            if lang == "1"
              test_hash[base_menu_material_id] = ["#{mm.material.category_before_type_cast}-#{mm.material.name}",mm.material.name,(mm.amount_used*num).round(1),mm.material.recipe_unit,mm.post,mm.preparation,"#{menu.name} (#{num})"]
            else
              test_hash[base_menu_material_id] = ["#{mm.material.category_before_type_cast}-#{mm.material.name}",mm.material.roma_name,(mm.amount_used*num).round(1),mm.material.recipe_unit,mm.post,mm.preparation,"#{menu.roma_name} (#{num})"]
            end
          end
        end
      end
    end

    test_hash.each do |key, value|
      if value[4] == '調理場' || value[4] == '切出/調理'
        menu_materials_arr_cook << value
      elsif value[4] == '切出し' || value[4] == '切出/スチ' || value[4] == '切出/調理'
        menu_materials_arr_cut << value
      end
    end
    menu_materials_arr_cut = menu_materials_arr_cut.sort { |a, b| a[0] <=> b[0]}
    menu_materials_arr_cook = menu_materials_arr_cook.sort { |a, b| a[0] <=> b[0]}
    start_page_count = 0
    if mochiba == "0"
      text "切り出し  #{date}"
      move_down 2
      table_content(menu_materials_arr_cut,mochiba,start_page_count)
      start_page_count = page_count
      start_new_page
      text "調理場  #{date}"
      move_down 2
      table_content(menu_materials_arr_cook,mochiba,start_page_count)
    elsif mochiba == "1"
      text "切り出し  #{date}"
      move_down 2
      table_content(menu_materials_arr_cut,mochiba,start_page_count)
    elsif mochiba == "2"
      text "調理場  #{date}"
      move_down 2
      table_content(menu_materials_arr_cook,mochiba,start_page_count)
    end
  end

  def table_content(menu_materials_arr,mochiba,start_page_count)
    move_down 10
    table line_item_rows(menu_materials_arr) do
      self.row_colors = ["f5f5f5", "FFFFFF"]
      cells.padding = 6
      cells.size = 8
      cells.border_width = 0.1
      cells.valign = :center
      column(1).align = :right
      columns(4).size = 7
      columns(5).size = 6
      row(0).column(2).align = :left
      self.header = true
      self.column_widths = [160,60,30,60,250,260]
    end
    page_count.times do |i|
      unless i < start_page_count
        go_to_page(i+1)
        bounding_box([bounds.right-50, bounds.top - 5], :width => 50) {
          text "#{i+ 1 -start_page_count} / #{page_count - start_page_count}"
        }
      end
    end
  end

  def line_item_rows(menu_materials_arr)
    data = [['食材名',{:content => "分量", :colspan => 2},{:content => "仕込み", :colspan => 2},'メニュー名']]
    menu_materials_arr.each do |mma|
        data << [mma[1],mma[2],mma[3],mma[4],mma[5],mma[6]]
    end
    data
  end
  def sen
    stroke_axis
  end
end
