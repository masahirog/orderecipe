class PreparationPdf < Prawn::Document
  def initialize(daily_menu)
    super(
      page_size: 'A4',
      page_layout: :landscape)
    font "vendor/assets/fonts/ipaexm.ttf"
    x = -10
    date = daily_menu.start_time
    daily_menu.daily_menu_details.each_with_index do |dmd,i|
      product = dmd.product
      num = dmd.manufacturing_number
      date(date)
      title(num,product,x,525)
      move_down 3
      title_yoki(num,product,x)
      move_down 3
      table_prepa(prepa_item_rows("切出し", product, num),x)
      move_down 10
      table_prepa(prepa_item_rows("切出/調理", product, num),x)
      move_down 10
      table_prepa(prepa_item_rows("調理場", product, num),x)
      move_down 10
      table_prepa(prepa_item_rows("切出/スチコン", product, num),x)

      if i ==1||i==3
        start_new_page
        x = 0
      else
        x += 400
      end
    end
  end
  def date(order)
    bounding_box([-10, 540], :width => 320) do
    end
  end
  def title(num,product,x,y)
    bounding_box([x, y], :width => 320) do
      text "#{num}食　：#{product.name}", size: 9
    end
  end

  def title_yoki(num,product,x)
    bounding_box([x, cursor], :width => 150) do
      text "#{product.menus[0].materials[0].name}　＜#{num}セット＞", size: 8
    end
  end
  def preparation_title(a,x)
    bounding_box([x,cursor], :width => 190) do
      text a, size: 8,styles: :bold
    end
  end
  def table_prepa(b,x)
    bounding_box([x,cursor], :width => 380) do
      b.each_with_index do |bb,i|
        if bb[1].present?
          next
        else
          @i = i
          break
        end
      end

      if @i<4
        size = 9
      elsif @i<5
        size = 8
      elsif @i<7
        size = 7
      else
        size = 6
      end

      table b, cell_style: { size: size,align: :left } do
        cells.padding = 2
        row(0).background_color = "E8E8E8"
        column(0).borders = [:bottom,:top,:left]
        column(1..3).borders = [:bottom,:top]
        column(3).borders = [:bottom,:top,:right]
        style column(0), :size => 6
        column(0).padding = [3,8,3,3]
        style row(0), :size => 7
        row(0).border_width = 1.5
        row(1..-2).border_lines =  [:dotted, :solid, :dotted, :solid]
        row(-1).border_lines =  [:dotted, :solid, :solid, :solid]
        column(2).align = :right
        column(2).padding = [1,5,1,1]
        cells.border_width = 0.2
        self.column_widths = [100,90,60,130]
      end
    end
  end

  def prepa_item_rows(c,product,num)
    data = []
    num = num
    if product.present?
      data << ["",c,"",""]
      product.menus.each do |menu|
        u = 0
        menu.menu_materials.each do |mema|
          u += 1 if mema.post == c
        end
        ii = 0
        menu.menu_materials.each_with_index do |mm,i|
          if mm.post == c && ii == 0  && mm.post == "調理場"
            data << [{:content => "#{menu.name} \n \n ----------メモ---------- \n #{menu.recipe}", :rowspan => u},"#{mm.material.name}", "#{(mm.amount_used * num.to_i).round.to_s(:delimited)} #{mm.material.calculated_unit}",
            "#{mm.preparation}"]
            ii = 1
            u += 1
          elsif mm.post == c && ii == 0
              data << [{:content => "#{menu.name}", :rowspan => u},"#{mm.material.name}", "#{(mm.amount_used * num.to_i).round.to_s(:delimited)} #{mm.material.calculated_unit}",
              "#{mm.preparation}"]
              ii = 1
              u += 1
          elsif mm.post == c && ii == 1
            data << ["#{mm.material.name}", "#{(mm.amount_used * num.to_i).round.to_s(:delimited)} #{mm.material.calculated_unit}",
            "#{mm.preparation}"]
            u += 1
         end
        end
      end
      data += [["","","",""]]
      data
    end
  end
  def sen
    stroke_axis
  end
end
