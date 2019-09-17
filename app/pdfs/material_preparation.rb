class MaterialPreparation < Prawn::Document
  def initialize(bentos_num_h,date,mochiba)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    menus = []
    menu_materials_choriba_arr = []
    menu_materials_kiriba_arr = []
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
        menu = Menu.includes(menu_materials:[:material]).find(menu_num[0])
        num = menu_num[1]
        menu.menu_materials.each do |mm|
          if mm.material.vegetable_flag == true
            base_menu_material_id = mm.base_menu_material_id
            if test_hash[base_menu_material_id]
              test_hash[base_menu_material_id][2] =(test_hash[base_menu_material_id][2] + mm.amount_used * num).round(1)
              test_hash[base_menu_material_id][6] += "／／#{menu.name}"
            else
              test_hash[base_menu_material_id] = [mm.material_id,mm.material.name,(mm.amount_used*num).round(1),mm.material.recipe_unit,mm.post,mm.preparation,menu.name]
            end
          end
        end
      end
    end
    test_hash.each do |key, value|
      menu_materials_choriba_arr << value if value[4] == '調理場' || value[4] == '切出/調理'
      menu_materials_kiriba_arr << value if value[4] == '切出し' || value[4] == '切出/スチ' || value[4] == '切出/調理'
    end
    menu_materials_choriba_arr = menu_materials_choriba_arr.sort { |a, b| b[0] <=> a[0] }
    menu_materials_kiriba_arr = menu_materials_kiriba_arr.sort { |a, b| b[0] <=> a[0] }
    # if mochiba == 'choriba'
    #   text "調理場  #{date}"
    #   move_down 2
    #   table_content(menu_materials_choriba_arr,'調理場')
    # elsif mochiba == 'kiriba'
    #   text "切出し  #{date}"
    #   move_down 2
    #   table_content(menu_materials_kiriba_arr,'切出し')
    # else
    #   text "調理場  #{date}"
    #   move_down 2
    #   table_content(menu_materials_choriba_arr,'調理場')
    #
    #   start_new_page
    #
    #   text "切出し  #{date}"
    #   move_down 2
    #   table_content(menu_materials_kiriba_arr,'切出し')
    # end
    text "くるめし仕込み：食材別シート  #{date}"
    move_down 2
    table_content(menu_materials_kiriba_arr,'切出し')

  end

  def table_content(menu_materials_arr,mochiba)
    move_down 10
    table line_item_rows(menu_materials_arr) do
      row(0).background_color = 'f5f5f5'
      cells.padding = 6
      cells.size = 9
      cells.border_width = 0.1
      cells.valign = :center
      column(1).align = :right
      columns(5).size = 6
      row(0).column(2).align = :left
      self.header = true
      self.column_widths = [220,60,30,60,300,150]
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
