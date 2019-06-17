class OrderPrintAll < Prawn::Document
  def initialize(order)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexm.ttf"
    order_materials = order.order_materials.where(un_order_flag:false)
    vendor_ids = order_materials.map{|om|om.material.vendor_id}.uniq

    vendor_ids.each_with_index do |vendor_id,i|
      company_name = Vendor.find(vendor_id).company_name
      oms = order_materials.joins(:material).where(:materials => {vendor_id:vendor_id})
      uniq_date = oms.pluck(:delivery_date).uniq
      uniq_date.each do |date|
        arr=[]
        oms.each do |om|
          arr << om if om.delivery_date == date
        end
        header
        header_lead(company_name)
        header_adress
        header_hello
        move_down 20
        table_content(arr,date)
        start_new_page unless i + 1 == vendor_ids.length
      end
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

  def header_adress
    bounding_box([330, 690], :width => 200, :height =>60) do
      font_size 10
      text "タベル株式会社", :leading => 3
      text "(弁当将軍キッチン)", :leading => 3
      text "〒164-0003 東京都中野区東中野1-35-1", :leading => 3
      text "TEL：03-5937-5431", :leading => 3
    end
  end

  def header_hello
    bounding_box([20, 690], :width => 200, :height => 50) do
      font_size 10
      text "いつも大変お世話になっております。", :leading => 3
      text "下記の通り発注致します。", :leading => 3
      text "どうぞよろしくお願い致します。", :leading => 3
    end
  end

  def table_content(arr,date)
    bounding_box([0,cursor], :width => 530) do
      table line_item_rows(arr,date), cell_style: { size: 9,height: 20,:overflow => :shrink_to_fit } do
        row(0).size = 12
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

  def line_item_rows(arr,date)
    data= [[{:content => "#{date.strftime("%Y年%-m月%-d日(#{%w(日 月 火 水 木 金 土)[date.wday]})")} 納品分",colspan:4}]]
    data<< ["管理コード","品名","数量","備考"]
    arr.each do |mtv|
      s_data = []
      data << ["#{mtv.material.order_code}","#{mtv.material.order_name}","#{mtv.order_quantity}  #{mtv.material.order_unit}","#{mtv.order_material_memo}"]
    end
     data += [["","","",""]] * 2
  end
end
