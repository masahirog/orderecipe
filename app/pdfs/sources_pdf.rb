class SourcesPdf < Prawn::Document
  def initialize(from,to,controler)

    # 初期設定。ここでは用紙のサイズを指定している。
    super(page_size: 'A4',page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    daily_menus = DailyMenu.where(start_time:from..to)
    daily_menu_details = DailyMenuDetail.includes([:daily_menu,product:[menus:[menu_materials:[:material]]]]).where(daily_menu_id:daily_menus.ids)
    material_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    daily_menu_details.each do |dmd|
      dmd.product.menus.each do |menu|
        if hash[menu.id][dmd.daily_menu.start_time].present?
          hash[menu.id][dmd.daily_menu.start_time] += dmd.manufacturing_number
        else
          hash[menu.id][dmd.daily_menu.start_time] = dmd.manufacturing_number
        end
        menu.menu_materials.each do |mm|
          if mm.post == "タレ"
            if material_hash[mm.material_id].present?
              material_hash[mm.material_id][:amount] += (dmd.manufacturing_number * mm.amount_used)
            else
              material_hash[mm.material_id][:amount] = (dmd.manufacturing_number * mm.amount_used)
              material_hash[mm.material_id][:material] = mm.material
            end            
          end
        end
      end
    end
    material_table_content(material_hash)
    start_new_page

    index = 0
    bounding_box([-5,540], :width => 880) {
      hash.each do |data|
        menu = Menu.find(data[0])
        if MenuMaterial.where(menu_id:menu.id).pluck(:post).include?("タレ")
          dates_num = data[1]
          start_new_page unless index == 0
          table_content(menu,dates_num)
          move_down 10
          index += 1
        end
      end
    }
    start_page_count = 0
    page_count.times do |i|
      unless i < start_page_count
        go_to_page(i+1)
        bounding_box([bounds.right-30, bounds.top+15], :width => 50) {
          text "#{i+ 1 -start_page_count} / #{page_count - start_page_count}"
        }
      end
    end

  end

   def material_table_content(material_hash)
    table material_rows(material_hash) do
      self.header = true
      self.column_widths = [300,100,50]
    end
  end
  def material_rows(material_hash)
    data = [['食材','量','単位']]
    material_hash.each do |material_data|
      data << [material_data[1][:material].name,(material_data[1][:amount]/material_data[1][:material].accounting_unit_quantity).round(1),material_data[1][:material].accounting_unit]
    end
    data
  end
 

  def table_content(menu,dates_num)
    table line_item_rows(menu,dates_num) do
      mm_counts = menu.materials.count
      if mm_counts > 30
        size = 6
      elsif mm_counts > 25
        size = 7
      elsif mm_counts > 20
        size = 8
      else
        size = 9
      end
      cells.size = size
      column(0).size = 7
      column(0).row(0).size = 8
      column(-1).size = 7
      cells.leading = 2
      cells.borders = [:bottom]
      cells.border_width = 0.2
      column(1).align = :right
      column(2).align = :center
      column(3..-2).align = :center
      row(0).border_width = 1
      self.header = true
      row_count = [80]*dates_num.count
      self.column_widths = [40,140,50,row_count,150].flatten
      grayout = []
      menuline = []
      values = cells.columns(0).rows(1..-1)
      values.each do |cell|
        grayout << cell.row unless cell.content == 'タレ'
      end
      grayout.each do |num|
        row(num).background_color = "dcdcdc"
      end
    end
  end
  def line_item_rows(menu,dates_num)
    row_0 = []
    dates_num.each do |date_num|
      date = date_num[0].strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[date_num[0].wday]})")
      num = date_num[1]
      row_0 << "#{date}\n#{num}人"
    end
    data= [[{:content => "#{menu.short_name}\n(#{menu.name})",colspan:2},"グループ",row_0,"仕込み内容"].flatten]
    u = menu.materials.length
    menu.menu_materials.each_with_index do |mm,i|
      if menu.category == "容器"
      else
        if mm.post == 'タレ'
          preparation = mm.preparation
        else
          preparation = ''
        end

        amount_data = []
        dates_num.each do |date_num|
          num = date_num[1]
          amount_data << "#{ActiveSupport::NumberHelper.number_to_rounded((mm.amount_used * num.to_i), strip_insignificant_zeros: true, :delimiter => ',', precision: 1)} #{mm.material.recipe_unit}"
        end
        if i == 0
          data << [{:content => "#{mm.post.slice(0..3)}" },
            {:content => "#{mm.material.name}" },
            {:content => "#{mm.source_group}",:align => :center },
            amount_data,
            {:content => "#{preparation}"}].flatten
        else
          data << [{:content => "#{mm.post.slice(0..3)}" },
            {:content => "#{mm.material.name}" },
            {:content => "#{mm.source_group}",:align => :center },
            amount_data,
            {:content => "#{preparation}" }].flatten
        end

      end
    end
    data
  end

  def sen
    stroke_axis
  end
end
