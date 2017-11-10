class OrderAll < Prawn::Document
  def initialize(order,order_materials,vendors)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexm.ttf"
    order = order
    order_materials = order_materials
    max = vendors.length - 1
    for i in 0..max
      sen2
      u= "id#{i}"
      id = vendors[u].to_i

      ordermaterials = order_materials
      materials_this_vendor = []
      ordermaterials.each do |om|
        vendorid = om.material.vendor_id
        if id == vendorid
          materials_this_vendor << om
        end
      end
      header
      header_lead(id)
      header_date(order)
      header_adress
      header_hello
      table_content(materials_this_vendor,order_materials)
      start_new_page if i < max
      i += 1
    end
  end

  def header
    bounding_box([170, 770], :width => 120, :height => 50) do
      text "発 注 書", size: 24
    end
  end

  def header_lead(id)
    bounding_box([0, 720], :width => 270, :height => 50) do
      font_size 10.5
      text "#{Vendor.find(id).company_name}　御中", size: 15
    end
  end
  def header_date(order)
    bounding_box([280, 730], :width => 140, :height => 20) do
        font_size 10.5
        text "#{order.delivery_date.strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[order.delivery_date.wday]})")} 納品分"
    end
  end
  def header_adress
    bounding_box([260, 690], :width => 160, :height => 50) do
        font_size 8.5
        text "株式会社ベントー・ドット・ジェーピー"
        text "(弁当将軍キッチン)"
        text "〒164-0003 東京都中野区東中野1-35-1"
        text "TEL：03-5937-5431"
    end
  end
  def header_hello
    bounding_box([20, 690], :width => 200, :height => 50) do
        font_size 8.5
        text "いつも大変お世話になっております。"
        text "下記の通り発注致します。"
        text "どうぞよろしくお願い致します。"
    end
  end
  def sen2
    stroke_color "F0F0F0"
    stroke_vertical_line 0, 800, :at => 450
  end

  def table_content(materials_this_vendor,order_materials)
    bounding_box([0, 640], :width => 530) do
      l = materials_this_vendor.length
      if l < 10
        u = 15 - l
      elsif l < 20
        u = 25 - l
      else
        u = 3
      end

      table line_item_rows(materials_this_vendor,u,order_materials), cell_style: { size: 9 } do
        row(0).height = 18
        row(l+1..l+u).height = 18
        cells.padding = 4
        column(-1).align = :right
        columns(4).borders = [:left]
        columns(5).borders = [:bottom]
        cells.border_width = 0.2
        self.header = true
        self.column_widths = [80,240,60,40,50,60]
        end
        text "　"
        text "＜備考＞", size: 11
      end
    end
  def line_item_rows(materials_this_vendor,u,order_materials)
    data= [["管理コード","品名","数量","単位","","計算欄"]]
    materials_this_vendor.each do |mtv|
      s_data = []
      data << ["#{mtv.material.order_code}","#{mtv.material.order_name}","","","",
        "#{mtv.calculated_quantity.to_s(:delimited)}" "#{mtv.material.calculated_unit}"]
    end
     data += [["","","","","",""]] * u
  end

  # def sen
  #   stroke_axis
  # end
end
