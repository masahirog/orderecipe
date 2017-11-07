class PreparationPdf < Prawn::Document
  def initialize(order)
    super(
      page_size: 'A4',
      page_layout: :landscape)
    font "vendor/assets/fonts/ipaexm.ttf"
    order_products = order.order_products
    x = 0
    order_products.each_with_index do |op,i|
      id = op.product_id
      num = op.serving_for
      date(order)
      title(num,id,x,510)
      move_down 3
      title_yoki(num,id,x)
      move_down 3
      table_prepa(prepa_item_rows("切り出し", id, num),x)
      move_down 20
      table_prepa(prepa_item_rows("切出/調理場", id, num),x)
      move_down 20
      table_prepa(prepa_item_rows("調理場", id, num),x)
      if i ==1
        start_new_page
        x = 0
      else
        x += 380
      end
    end
  end
  def date(order)
    bounding_box([0, 525], :width => 300) do
      text "#{order.delivery_date.strftime("%Y年")}　　　月　　　日（　　）"
    end
  end
  def title(num,id,x,y)
    bounding_box([x, y], :width => 190) do
      text "#{num}食　：#{Product.find(id).name}", size: 9
    end
  end

  def title_yoki(num,id,x)
    bounding_box([x, cursor], :width => 150) do
      text "#{Product.find(id).menus[0].materials[0].name}　＜#{num}セット＞", size: 8
    end
  end
  def preparation_title(a,x)
    bounding_box([x,cursor], :width => 190) do
      text a, size: 8,styles: :bold
    end
  end
  def table_prepa(b,x)
    bounding_box([x,cursor], :width => 370) do
      b.each_with_index do |bb,i|
        if bb[1].present?
          next
        else
          @i = i
          break
        end
      end

      if @i<4
        size = 11
      elsif @i<5
        size = 10
      elsif @i<7
        size = 9
      else
        size = 7
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
        self.column_widths = [80,90,60,130]
      end
    end
  end

  def prepa_item_rows(c,id,num)
    data = []
    id = id
    num = num
    if id.present?
      menus = Product.find(id).menus
      data << ["",c,"",""]
      menus.each do |menu|
        u = menu.menu_materials.where(post: c).count
        ii = 0
        menu.menu_materials.each_with_index do |mm,i|
          if mm.post == c && ii == 0
            data << [{:content => "#{menu.name}", :rowspan => u},"#{mm.material.name}", "#{(mm.amount_used * num.to_i).round.to_s(:delimited)} #{mm.material.calculated_unit}",
            "#{mm.preparation}"]
            ii = 1
          elsif mm.post == c && ii == 1
            data << ["#{mm.material.name}", "#{(mm.amount_used * num.to_i).round.to_s(:delimited)} #{mm.material.calculated_unit}",
            "#{mm.preparation}"]
          end
        end
      end
      data += [["　","　","　","　"]]*(2)
      data
    end
  end
  def sen
    stroke_axis
  end
end
