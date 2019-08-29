class OrderPdf < Prawn::Document
  def initialize(materials_this_vendor,vendor,order)
    super(page_size: 'A4')
    uniq_date = materials_this_vendor.pluck(:delivery_date).uniq
    font "vendor/assets/fonts/ipaexm.ttf"
    uniq_date.each_with_index do |date,i|
      arr=[]
      materials_this_vendor.each do |material|
        arr << material if material.delivery_date == date
      end
      start_new_page unless i == 0
      header(order)
      header_lead(vendor)
      header_adress(vendor)
      header_hello
      table_content(arr,date)
    end
  end

  def header(order)
    text "オーダーID：#{order.id}",:align => :right
    bounding_box([200, 770], :width => 120, :height => 50) do
      text "発 注 書", size: 24
    end
  end

  def header_lead(vendor)
    bounding_box([0, 720], :width => 270, :height => 50) do
      font_size 9
      text "#{vendor.company_name}　御中", size: 15
      move_down 4
      text "　　TEL：#{vendor.company_phone}　　FAX：#{vendor.company_fax}"
    end
  end

  def header_adress(vendor)
    bounding_box([330, 700], :width => 200, :height =>70) do
        font_size 10
        text "タベル株式会社", :leading => 3
        text "No：#{vendor.management_id}", :leading => 3 if vendor.management_id.present?
        text "〒164-0003 東京都中野区東中野1-35-1", :leading => 3
        text "TEL：03-5937-5431", :leading => 3
        text "FAX：03-5937-5432", :leading => 3
    end
  end
  def header_hello
    bounding_box([20, 685], :width => 200, :height => 50) do
        font_size 10
        text "いつも大変お世話になっております。", :leading => 3
        text "下記の通り発注致します。", :leading => 3
        text "どうぞよろしくお願い致します。", :leading => 3
    end
  end

  def table_content(arr,date)
    bounding_box([0,630], :width => 530) do
      table line_item_rows(arr,date), cell_style: { size: 9 ,height: 20,:overflow => :shrink_to_fit } do
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
    data<< ["商品コード","品名","数量","備考"]
    arr.each do |mtv|
      s_data = []
      data << ["#{mtv.material.order_code}","#{mtv.material.order_name}","#{((mtv.order_quantity.to_f/mtv.material.recipe_unit_quantity)*mtv.material.order_unit_quantity).round(1)}  #{mtv.material.order_unit}","#{mtv.order_material_memo}"]
    end
     data += [["","","",""]] * 2
  end
end
