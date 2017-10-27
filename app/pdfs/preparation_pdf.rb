class PreparationPdf < Prawn::Document
  def initialize(params)
    super(
      page_size: 'A4',
      page_layout: :landscape)
    font "vendor/assets/fonts/ipaexm.ttf"
    @params = params
    x = 0
    for i in 0..3
      id = params["id#{i}"]
      if id.present?
        if x == 0
          preparation_title("[切り出し]",x,510)
          preparation_title("[調理場]",x,310)
          preparation_title("[切出/調理場]",x,120)
        end
        title(id,x+40,520)
        table_prepa(prepa_item_rows("切り出し", i),x,500)
        table_prepa(prepa_item_rows("調理場", i),x,300)
        table_prepa(prepa_item_rows("切出/調理場", i),x,110)
        x += 190
      end
    end
  end
  def title(id,x,y)
    bounding_box([x, y], :width => 150) do
      text "#{Product.find(id).name}", size: 8
    end
  end

  def preparation_title(a,x,y)
    bounding_box([x, y], :width => 190) do
      text a, size: 8,styles: :bold
    end
  end
  def table_prepa(b,x,y)
    bounding_box([x, y], :width => 185) do
      table b, cell_style: { size: 7,align: :left } do
        cells.padding = 2
        column(0).borders = [:bottom,:top,:left]
        column(1..2).borders = [:bottom,:top]
        column(2).borders = [:bottom,:top,:right]
        row(0).border_lines =  [:solid, :solid, :dotted, :solid]
        row(1..-2).border_lines =  [:dotted, :solid, :dotted, :solid]
        row(-1).border_lines =  [:dotted, :solid, :solid, :solid]


        column(1).align = :right
        column(1).padding = [1,3,1,1]
        column(2).padding = [1,1,1,4]
        cells.border_width = 0.2
        self.column_widths = [60,50,75]
      end
    end
  end

  def prepa_item_rows(c,i)
    data = []
    product_id = @params["id#{i}"]
    num = @params["num#{i}"]
    if product_id.present?
      @menus = Product.find(product_id).menus
      @menus.each do |menu|
        u = menu.materials.length
        menu.menu_materials.each do |mm|

          if mm.post == c
            data << ["#{mm.material.name}", "#{(mm.amount_used * num.to_i).round.to_s(:delimited)} #{mm.material.calculated_unit}",
            "#{mm.preparation}"]
          end
        end
      end

      l = data.length
      if c == "切出/調理場"

        if l < 8
          data += [["　","　","　"]]*(8-l)
        else
          data
        end
      else
        if l < 10
          data += [["　","　","　"]]*(10-l)
        elsif l <15
          data += [["　","　","　"]]*(15-l)
        else
          data
        end
      end
    end
  end





  def sen
    stroke_axis
  end
end
