class KurumesiPreperationTodayCheck < Prawn::Document
  def initialize(bentos_num_h,date,lang)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    menus = []
    menu_materials_arr = []
    products_arr = []
    hash = Hash.new { |h,k| h[k] = {} }
    arr_hon = []
    bentos_num_h.each do |prnm|
      product = Product.find(prnm[0])
      num = prnm[1]
      product.menus.each do |menu|
        if menu.cook_on_the_day.present?
          if hash[menu.base_menu_id].present?
            if hash[menu.base_menu_id][menu.id].present?
              hash[menu.base_menu_id][menu.id][0] += num
            else
              hash[menu.base_menu_id].store(menu.id,[num,menu.cook_on_the_day])
            end
          else
            hash.store(menu.base_menu_id, {menu.id => [num,menu.cook_on_the_day]})
          end
        end
      end
    end
    text "くるめし当日調理一覧  #{date}"
    move_down 2
    table_content(hash,lang)
    page_count.times do |i|
      go_to_page(i+1)
      bounding_box([bounds.right-50, bounds.top - 5], :width => 50) {
        text "#{i+1} / #{page_count}"
      }
    end
  end

  def table_content(hash,lang)
    move_down 10
    table line_item_rows(hash,lang) do
      self.row_colors = ["f5f5f5", "FFFFFF"]
      cells.padding = 6
      cells.size = 8
      cells.border_width = 0.1
      cells.valign = :center
      row(0).column(2).align = :left
      self.header = true
      self.column_widths = [300,500]
    end
  end

  def line_item_rows(hash,lang)
    data = [['メニュー名','調理内容']]
    hash.each do |key,val|
      menu = Menu.find(key)
      menu_name_num = []
      cook_on_the_day = []
      val.each do |key2,val2|
        if lang == "日本語"
          menu_name_num << "#{Menu.find(key2).name}(#{val2[0]})"
        else
          menu_name_num << "#{Menu.find(key2).roma_name}(#{val2[0]})"
        end
        cook_on_the_day << val2[1]
      end
      data << [menu_name_num.join("\n―　―　―　―　―　―　―　―　―　―\n"),cook_on_the_day.join("\n―　―　―　―　―　―　―　―　―　―\n")]
    end
    data
  end
  def sen
    stroke_axis
  end
end
