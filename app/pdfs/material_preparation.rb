class MaterialPreparation < Prawn::Document
  def initialize(bentos_num_h,date,mochiba,lang,sort,category)
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
        if category == "0"
          menu_materials = menu.menu_materials.includes(:material).order('materials.category').where(:materials => {measurement_flag:true})
        else
          menu_materials = menu.menu_materials.includes(:material).order('materials.category').where(:materials => {measurement_flag:true,category:category})
        end

        menu_materials.each do |mm|
          base_menu_material_id = mm.base_menu_material_id
          machine = "○" if mm.machine_flag == true
          first = "○" if mm.first_flag == true
          group = mm.source_group if mm.source_group.present?
          amount = ActiveSupport::NumberHelper.number_to_rounded((mm.amount_used*num), strip_insignificant_zeros: true, :delimiter => ',')
          if test_hash[base_menu_material_id]
            # test_hash[base_menu_material_id][2] =(test_hash[base_menu_material_id][2] + mm.amount_used * num).round(1)
            # if lang == "1"
            #   test_hash[base_menu_material_id][6] += "、#{menu.name}（#{num}）"
            # else
            #   test_hash[base_menu_material_id][6] += "、#{menu.roma_name}（#{num}）"
            # end
          else
            if lang == "1"
              test_hash[base_menu_material_id] = ["#{mm.material.category_before_type_cast}-#{mm.material.name}",mm.material.name,amount,"#{amount} #{mm.material.recipe_unit}",mm.post,mm.preparation,"#{menu.name} (#{num})",first,machine,group]
            else
              test_hash[base_menu_material_id] = ["#{mm.material.category_before_type_cast}-#{mm.material.name}",mm.material.roma_name,amount,mm.material.recipe_unit,mm.post,mm.preparation,"#{menu.roma_name} (#{num})",first,machine,group]
            end
          end
        end
      end
    end

    test_hash.each do |key, value|
      unless value[4] == ""
        if value[4] == '調理場'
          menu_materials_arr_cook << value
        elsif value[4] == '切出し'
          menu_materials_arr_cut << value
        elsif value[4] == '切出/調理' || value[4] == '切出/スチ'
          menu_materials_arr_cook << value
          menu_materials_arr_cut << value
        end
      end
    end
    if sort == 1
      i = 4
    else
      i = 6
    end
    menu_materials_arr_cut = menu_materials_arr_cut.sort { |a, b| a[0] <=> b[0]}.sort { |a, b| a[i] <=> b[i]}
    menu_materials_arr_cook = menu_materials_arr_cook.sort { |a, b| a[0] <=> b[0]}.sort { |a, b| a[i] <=> b[i]}
    start_page_count = 0
    if mochiba == "0"
      mochiba = '切り出し'
      table_content(menu_materials_arr_cut,mochiba,start_page_count,date)
      start_page_count = page_count
      start_new_page
      mochiba = '調理場'
      table_content(menu_materials_arr_cook,mochiba,start_page_count,date)
    elsif mochiba == "1"
      mochiba = '切り出し'
      table_content(menu_materials_arr_cut,mochiba,start_page_count,date)
    elsif mochiba == "2"
      mochiba = '調理場'
      table_content(menu_materials_arr_cook,mochiba,start_page_count)
    end
  end

  def table_content(menu_materials_arr,mochiba,start_page_count,date)
    table line_item_rows(menu_materials_arr,date,mochiba) do
      self.row_colors = ["f5f5f5", "FFFFFF"]
      cells.padding = 6
      cells.size = 8
      cells.border_width = 0.1
      cells.valign = :center
      column(3).align = :right
      columns(7).size = 6
      row(0).column(2).align = :left
      self.header = true
      self.column_widths = [140,20,20,60,60,20,230,230]
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

  def line_item_rows(menu_materials_arr,date,mochiba)
    data = [["#{mochiba}  #{date}",'F','M',"分量", {:content => "仕込み", :colspan => 3},'メニュー名']]
    menu_materials_arr.each do |mma|
        data << [mma[1],mma[7],mma[8],mma[3],mma[4],mma[9],mma[5],mma[6]]
    end
    data
  end
  def sen
    stroke_axis
  end
end
