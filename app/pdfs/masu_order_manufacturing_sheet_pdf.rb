class MasuOrderManufacturingSheetPdf < Prawn::Document
  def initialize(products_num_h,date,masu_orders)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    masu_orders_arr = masu_orders.each_slice(6).to_a
    masu_orders_arr.each_with_index do |moa,i|
      table_content(products_num_h,date,moa,i)
      start_new_page unless i + 1 == masu_orders_arr.length
    end
  end

  def table_content(products_num_h,date,moa,i)
    bounding_box([20, 550], :width => 840) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}　　No.#{i + 1}",size:10
      move_down 10
      table line_item_rows2(products_num_h,date,moa) do
        row(0..2).background_color = 'f5f5f5'
        cells.padding = 6
        cells.size = 10
        columns(0).size = 8
        columns(1).size = 10
        row(0..1).columns(0).size = 10

        cells.border_width = 0.1
        cells.valign = :center
        columns(2..-1).align = :center
        self.header = true
        columns = Array.new(moa.length){60}
        self.column_widths = [250,100].push(columns).flatten!
      end

    end
  end

  def line_item_rows2(products_num_h,date,moa)
    total = products_num_h.values.inject(:+)
    hash = {}
    moa_ids = moa.map{|mo|mo.id}
    MasuOrderDetail.where(masu_order_id:moa_ids).each do |mso|
      hash.store([mso.masu_order_id,mso.product_id], mso.number)
    end
    kurumesi_ids = moa.map{|masu_order| masu_order.kurumesi_order_id}
    data = [["配達日：  #{date}","オーダーID▶",''].push(kurumesi_ids).flatten!]
    data << ["","ピックアップ",'▼合計'].push(moa.map{|mo|mo.pick_time.strftime("%R")}).flatten!
    products_num_h.each do |pnh|
      product_id = pnh[0]
      number = pnh[1]
      product = Product.find(product_id)
      arr = [product.name,product.short_name,number]
      moa.each do |masu_order|
        arr.push(hash[[masu_order.id,product.id]])
      end
      data << arr.map {|e| e ? e : ''}
    end
    total_num = ['','合計',total]
    moa.each do |masu_order|
      total_num.push(masu_order.number)
    end
    data << total_num
    data
  end
  def sen
    stroke_axis
  end
end
