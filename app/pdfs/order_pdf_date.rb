class OrderPdfDate < Prawn::Document
  def initialize(delivery_date,store_ids)
    super(page_size: 'A4')
    font "vendor/assets/fonts/ipaexg.ttf"
    stores = Store.where(id:store_ids)
    first_flag = true
    stores.each do |store|
      order_materials = OrderMaterial.includes(:order,:material).joins(:order).where(:orders => {store_id:store.id,fixed_flag:true}).where(delivery_date:delivery_date).where(un_order_flag:false)
      vendor_ids = order_materials.map{|om|om.material.vendor_id}.uniq
      vendor_ids.each do |vendor_id|
        if vendor_id == 559
        else
          vendor = Vendor.find(vendor_id)
          oms = order_materials.joins(:material).where(:materials => {vendor_id:vendor_id})
          length = oms.each_slice(25).to_a.length
          oms.each_slice(25).to_a.each_with_index do |data,i|
            start_new_page if first_flag == false
            header(delivery_date,i,length)
            header_lead(vendor)
            header_adress(store,vendor)
            table_content(data)
            first_flag = false
          end
        end
      end
    end
  end

  def header(delivery_date,i,length)
    text "納品日：#{delivery_date} 【#{i+1}/#{length}】",:align => :right, size: 14
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

  def header_adress(store,vendor)
    bounding_box([280, 700], :width => 250, :height =>100) do
      font_size 11
      text "拠点ID：#{store.orikane_store_code}", :leading => 3 if vendor.id == 171
      text "#{store.name}", :leading => 3
      font_size 9
      text "#{store.address}", :leading => 3
      text "TEL：#{store.phone}", :leading => 3
      text "No：#{vendor.management_id}", :leading => 3 if vendor.management_id.present?
      text "株式会社結び", :leading => 3
    end
  end

  def table_content(oms)
    bounding_box([0,630], :width => 530) do
      table line_item_rows(oms), cell_style: { size: 9,:overflow => :shrink_to_fit } do
        cells.padding = 4
        column(2).align = :center
        column(3).align = :center
        cells.border_width = 0.2
        self.header = true
        self.column_widths = [60,180,70,170,40]
      end
    end
  end

  def line_item_rows(oms)
    data = [["オーダーID","品名","数量","備考",'発注者']]
    oms.each do |om|
      amount = number_with_precision((om.order_quantity.to_f/om.material.recipe_unit_quantity)*om.material.order_unit_quantity,precision:1, strip_insignificant_zeros: true, delimiter: ',')
      data << ["#{om.order_id}","#{om.material.order_name}","#{amount}  #{om.material.order_unit}","#{om.order_material_memo}",om.order.staff_name]
    end
    data
  end
end
