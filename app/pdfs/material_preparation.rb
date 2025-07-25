class MaterialPreparation < Prawn::Document
  def initialize(daily_menu,date,mochiba,lang,sort,category)
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
    daily_menu.daily_menu_details.each do |dmd|
      product = dmd.product
      num = dmd.manufacturing_number
      products_arr << [product.name,num]
      product.product_menus.each do |pm|
        tpm = TemporaryProductMenu.find_by(product_menu_id:pm.id,daily_menu_detail_id:dmd.id)
        if tpm.present?
          menu = tpm.menu
        else
          menu = pm.menu
        end
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
        elsif category == "1"
          menu_materials = menu.menu_materials.includes(:material).order('materials.category').where(:materials => {measurement_flag:true}).where.not(:materials => {category:2})
        else
          menu_materials = menu.menu_materials.includes(:material).order('materials.category').where(:materials => {measurement_flag:true,category:2})
        end

        menu_materials.each do |mm|
          base_menu_material_id = mm.base_menu_material_id
          machine = "○" if mm.machine_flag == true
          first = "○" if mm.first_flag == true
          group = mm.source_group if mm.source_group.present?
          amount = mm.amount_used*num
          # amount = ActiveSupport::NumberHelper.number_to_rounded((mm.amount_used*num), strip_insignificant_zeros: true, :delimiter => ',')
          if test_hash[base_menu_material_id]
            test_hash[base_menu_material_id][2] = test_hash[base_menu_material_id][2] + mm.amount_used * num
            if lang == "1"
              test_hash[base_menu_material_id][6] += "、#{menu.name}（#{num}）"
            else
              test_hash[base_menu_material_id][6] += "、#{menu.short_name}（#{num}）"
            end
          else
            tmm = mm.temporary_menu_materials.find_by(date:date)
            if tmm.present?
              change_flag = '◯'
              if lang == "1"
                material_name=tmm.material.name
                menu_name=menu.name
              else
                material_name=tmm.material.short_name
                menu_name=menu.short_name
              end
            else
              change_flag = ''
              if lang == "1"
                material_name=mm.material.name
                menu_name=menu.name
              else
                material_name=mm.material.short_name
                menu_name=menu.short_name
              end              
            end
            test_hash[base_menu_material_id] = ["#{mm.material.category_before_type_cast}-#{material_name}",material_name,amount,mm.material.recipe_unit,mm.post,mm.preparation,"#{menu_name} (#{num})",first,machine,group,change_flag]
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
      table_content(menu_materials_arr_cook,mochiba,start_page_count,date)
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
      self.column_widths = [25,30,140,20,20,60,60,20,200,230]
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
    data = [["",'変更',"#{mochiba}  #{date}",'F','M',"分量", {:content => "仕込み", :colspan => 3},'メニュー名']]
    menu_materials_arr.each_with_index do |mma,i|
      amount = ActiveSupport::NumberHelper.number_to_rounded(mma[2], strip_insignificant_zeros: true, :delimiter => ',', precision: 1)
      data << ["#{i+1}",mma[10],mma[1],mma[7],mma[8],"#{amount} #{mma[3]}",mma[4],mma[9],mma[5],mma[6]]
    end
    data
  end
  def sen
    stroke_axis
  end
end
