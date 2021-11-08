class KurumesiMakeOrderPdf < Prawn::Document
  def initialize(date,kurumesi_orders,kurumesi_orders_num_h,products_num_h,brand_ids)
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    font "vendor/assets/fonts/ipaexg.ttf"
    brand_ids.each_with_index do |brand_id,ii|
      brand_kurumesi_orders = kurumesi_orders.where(brand_id:brand_id)
      brand_product_ids = KurumesiOrderDetail.joins(:kurumesi_order).order('kurumesi_orders.pick_time').where(kurumesi_order_id:brand_kurumesi_orders.ids).map{|kod|kod.product_id}.uniq
      kurumesi_orders_arr = brand_kurumesi_orders.each_slice(10).to_a
      memo = ''
      kurumesi_orders_arr.each_with_index do |moa,i|
        table_content(date,moa,kurumesi_orders_num_h,products_num_h,brand_id,brand_product_ids)
        if brand_kurumesi_orders.where.not(kitchen_memo: [nil, '']).present?
          brand_kurumesi_orders.where.not(kitchen_memo: [nil, '']).each do |ko|
            memo += "［　#{ko.management_id}：#{ko.kitchen_memo}　］"
          end
          move_down 3
          text memo
        end
        start_new_page unless i + 1 == kurumesi_orders_arr.length
      end
      start_new_page unless ii + 1 == brand_ids.length
    end
  end
  def table_content(date,moa,kurumesi_orders_num_h,products_num_h,brand_id,brand_product_ids)
    bounding_box([0, 570], :width => 820) do
      brand_name = Brand.find(brand_id).name
      text brand_name
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:9,:align => :right
      move_down 5
      table line_item_rows2(date,moa,kurumesi_orders_num_h,products_num_h,brand_product_ids,brand_id) do
        self.row_colors = ["E5E5E5", "FFFFFF"]
        cells.padding = [8,6,8,6]
        cells.size = 9
        cells.border_width = 0.1
        cells.valign = :center
        columns(1).size = 10
        row(0..1).columns(0).size = 10
        columns(2..-1).align = :center
        self.header = true
        columns = Array.new(moa.length){50}
        self.column_widths = [190,80,45].push(columns).flatten!
      end
    end
  end
  def line_item_rows2(date,moa,kurumesi_orders_num_h,products_num_h,brand_product_ids,brand_id)
    moa_ids = moa.map{|mo|mo.id}
    hash = {}
    KurumesiOrderDetail.where(kurumesi_order_id:moa_ids).each do |mso|
      hash.store([mso.kurumesi_order_id,mso.product_id], mso.number)
    end

    kurumesi_ids = moa.map do |kurumesi_order|
      if kurumesi_order.kitchen_memo.present?
        "#{kurumesi_order.management_id.to_s[-4..-1]} MEMO"
      else
        kurumesi_order.management_id.to_s[-4..-1]
      end
    end

    data = [["配達日： #{date}",'',""].push(kurumesi_ids).flatten!]
    arr2 = ['','','']
    moa.each do |kurumesi_order|
      if kurumesi_order.pick_time.present?
        arr2.push(kurumesi_order.pick_time.strftime("%R"))
      else
        arr2.push("")
      end
    end
    data << arr2
    kurumesi_order_ids = moa.map{|ko|ko.id}
    products = Product.where(product_category:5,id:brand_product_ids).order('product_category ASC').order("field(id, #{brand_product_ids.join(',')})")
    products.each do |product|
      arr = [product.name.truncate(24),"#{product.short_name}#{product.symbol}",products_num_h[product.id]]
      moa.each do |kurumesi_order|
        arr.push(hash[[kurumesi_order.id,product.id]])
      end
      data << arr.map {|e| e ? e : ''}
    end
    data
  end
  def sen
    stroke_axis
  end
end
