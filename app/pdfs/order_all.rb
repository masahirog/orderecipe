class OrderAll < Prawn::Document
  def initialize(order,vendors)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexm.ttf"
    order = order
    order_materials = order.order_materials
    max = vendors.length - 1
    for i in 0..max
      u= "id#{i}"
      id = vendors[u].to_i
      materials_this_vendor = []
      for om in order_materials do
        vendorid = om.material.vendor_id
        if id == vendorid
          company_name = om.material.vendor.company_name
          materials_this_vendor << om
        end
        company_name
      end
      header
      header_lead(company_name)
      header_date(order)
      header_adress
      header_hello
      table_content(materials_this_vendor)
      start_new_page if i < max
      i += 1
    end
  end

  def header
    bounding_box([200, 770], :width => 120, :height => 50) do
      text "発 注 書", size: 24
    end
  end

  def header_lead(company_name)
    bounding_box([0, 720], :width => 270, :height => 50) do
      font_size 10.5
      text "#{company_name}　御中", size: 15
    end
  end
  def header_date(order)
    bounding_box([380, 730], :width => 140, :height => 20) do
        font_size 10.5
        text "#{order.delivery_date.strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[order.delivery_date.wday]})")} 納品分"
    end
  end
  def header_adress
    bounding_box([330, 690], :width => 200, :height =>60) do
        font_size 10
        text "株式会社ベントー・ドット・ジェーピー"
        text "(弁当将軍キッチン)"
        text "〒164-0003 東京都中野区東中野1-35-1"
        text "TEL：03-5937-5431"
    end
  end
  def header_hello
    bounding_box([20, 690], :width => 200, :height => 50) do
        font_size 10
        text "いつも大変お世話になっております。"
        text "下記の通り発注致します。"
        text "どうぞよろしくお願い致します。"
    end
  end
  # def sen2
  #   stroke_color "F0F0F0"
  #   stroke_vertical_line 0, 800, :at => 450
  # end

  def table_content(materials_this_vendor)
    bounding_box([0, 640], :width => 530) do
      l = materials_this_vendor.length
      if l < 10
        u = 20 - l
      elsif l < 20
        u = 30 - l
      else
        u = 5
      end

      table line_item_rows(materials_this_vendor,u), cell_style: { size: 9,height: 20 } do
        cells.padding = 4
        column(-1).align = :right
        column(2).align = :center
        column(3).align = :center
        cells.border_width = 0.2
        self.header = true
        self.column_widths = [80,200,70,170]
        end
      end
    end
    def line_item_rows(materials_this_vendor,u)
    data= [["管理コード","品名","数量","備考"]]
    materials_this_vendor.each do |mtv|
      s_data = []
      data << ["#{mtv.material.order_code}","#{mtv.material.order_name}","#{mtv.order_quantity}  #{mtv.material.order_unit}","#{mtv.order_material_memo}"]
    end
     data += [["","","",""]] * u
  end

  # def sen
  #   stroke_axis
  # end
end
