class OrderPrintAll < Prawn::Document
  def initialize(order)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexg.ttf"
    order_materials = order.order_materials.where(un_order_flag:false)
    vendor_ids = order_materials.map{|om|om.material.vendor_id}.uniq

    vendor_ids.each_with_index do |vendor_id,i|
      vendor = Vendor.find(vendor_id)
      oms = order_materials.joins(:material).where(:materials => {vendor_id:vendor_id})
      hash = {}
      oms.map do |om|
        if hash[om.delivery_date].present?
          hash[om.delivery_date] << om
        else
          hash[om.delivery_date] = [om]
        end
      end
      hash.each_with_index do |data,ii|
        header(order)
        header_lead(vendor)
        header_adress(vendor,order)
        move_down 20
        table_content(data[1],data[0])
        start_new_page unless ii == (hash.length - 1) && i == (vendor_ids.length - 1)
      end
    end
  end

  def header(order)
    text "オーダーID：#{order.id}",:align => :right
    bounding_box([200, 770], :width => 120, :height => 50) do
      text "発 注 書", size: 24
    end
  end

  def header_lead(vendor)
    bounding_box([0, 720], :width => 270, :height => 100) do
      font_size 9
      text "#{vendor.company_name}　御中", size: 15
      if vendor.fax_staff_name_display_flag == true
        move_down 5
        text "ご担当：#{vendor.staff_name} 様"
      end
      move_down 5
      text "TEL：#{vendor.company_phone}　　FAX：#{vendor.company_fax}"
      move_down 5
      text "いつも大変お世話になっております。", :leading => 3
      text "下記の通り発注致します。", :leading => 3
      text "どうぞよろしくお願い致します。", :leading => 3
    end
  end

  def header_adress(vendor,order)
    bounding_box([280, 700], :width => 200, :height =>100) do
      font_size 11
      text "拠点ID：#{order.store.orikane_store_code}", :leading => 3 if vendor.id == 171
      text "#{order.store.name}", :leading => 3
      font_size 9
      text "#{order.store.address}", :leading => 3
      text "TEL：#{order.store.phone}", :leading => 3
      text "No：#{vendor.management_id}", :leading => 3 if vendor.management_id.present?
      if vendor.id == 11
        text "株式会社べじはん", :leading => 3
      else
        text "株式会社結び", :leading => 3
      end
    end
  end

  def table_content(arr,date)
    bounding_box([0,620], :width => 530) do
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
    data<< ["商品コード","品名","数量","備考"]
    arr.each do |mtv|
      s_data = []
      amount = number_with_precision((mtv.order_quantity.to_f/mtv.material.recipe_unit_quantity)*mtv.material.order_unit_quantity,precision:1, strip_insignificant_zeros: true, delimiter: ',')
      data << ["#{mtv.material.order_code}","#{mtv.material.order_name}","#{amount}  #{mtv.material.order_unit}","#{mtv.order_material_memo}"]
    end
     data += [["","","",""]] * 2
  end
end
