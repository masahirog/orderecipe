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

    menu_materials_choriba_arr = []
    menu_materials_kiriba_arr = []
    products_arr = []
    hash = {}
    bentos_num_h.each do |prnm|
      product = Product.includes(menus:[menu_materials:[:menu,material:[:storage_location]]]).find(prnm[0])
      num = prnm[1]
      products_arr << [product.name,prnm[1]]
      product.menus.each do |menu|
        menu.menu_materials.each do |mm|
          if hash[[mm.id,mm.material_id]]
            hash[[mm.id,mm.material_id]] = [mm,num + hash[[mm.id,mm.material_id]][1],hash[[mm.id,mm.material_id]][2] +"/"+ "#{product.short_name}:#{num}個"]
          else
            hash[[mm.id,mm.material_id]] = [mm,num,"#{product.short_name}:#{num}個"]
          end
        end
      end
    end
    hash.each do |key, value|
      menu_materials_choriba_arr << [value[0],value[1],value[2]] if value[0].post == '調理場' || value[0].post == '切出/調理'
      menu_materials_kiriba_arr << [value[0],value[1],value[2]] if value[0].post == '切出し' || value[0].post == '切出/スチコン' || value[0].post == '切出/調理'
    end
    menu_materials_choriba_arr = menu_materials_choriba_arr.sort { |a, b| b[0].material_id <=> a[0].material_id }
    menu_materials_kiriba_arr = menu_materials_kiriba_arr.sort { |a, b| b[0].material_id <=> a[0].material_id }

    if mochiba == 'choriba'
      text "調理場  #{date}"
      move_down 2
      table_content(menu_materials_choriba_arr,'調理場')
    elsif mochiba == 'kiriba'
      text "切出し  #{date}"
      move_down 2
      table_content(menu_materials_kiriba_arr,'切出し')
    else
      text "調理場  #{date}"
      move_down 2
      table_content(menu_materials_choriba_arr,'調理場')

      start_new_page

      text "切出し  #{date}"
      move_down 2
      table_content(menu_materials_kiriba_arr,'切出し')

    end
  end

  def table_content(menu_materials_arr,mochiba)
    move_down 10
    table line_item_rows(menu_materials_arr) do
      row(0).background_color = 'f5f5f5'
      cells.padding = 6
      cells.size = 9
      cells.border_width = 0.1
      cells.valign = :center
      column(2).align = :right
      columns(7).size = 6
      columns(6).size = 6
      row(0).column(2).align = :left
      self.header = true
      self.column_widths = [150,80,60,30,60,200,150,90]
    end
  end

  def line_item_rows(menu_materials_arr)
    data = [['食材名','保管場所',{:content => "分量", :colspan => 2},{:content => "仕込み", :colspan => 2},'メニュー名']]
    menu_materials_arr.each do |mma|
        data << [mma[0].material.name,mma[0].material.storage_location.name,(mma[0].amount_used * mma[1]).round(1),mma[0].material.calculated_unit,mma[0].post,mma[0].preparation,mma[0].menu.name,mma[2]]
    end
    data
  end
  def sen
    stroke_axis
  end
end
