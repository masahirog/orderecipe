class MasuOrderManufacturingSheetPdf < Prawn::Document
  def initialize(products_num_h,date)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexm.ttf"
    table_content(products_num_h,date)
  end

  def table_content(products_num_h,date)
    masu_orders = MasuOrder.where(start_time:date).order(:pick_time)
    total = products_num_h.values.inject(:+)

    bounding_box([20, 550], :width => 740) do
      text "配達日：  #{date}　　　　　　お弁当合計：　#{total} 個"
      move_down 10
      table line_item_rows(products_num_h,date,total) do
        row(0).background_color = 'f5f5f5'
        cells.padding = 6
        cells.size = 10
        cells.border_width = 0.1
        self.header = true
        self.column_widths = [500,160,50]
      end
      move_down 10
      table line_item_rows2(products_num_h,date,masu_orders) do
        row(0..1).background_color = 'f5f5f5'
        row(-1).background_color = 'f5f5f5'
        cells.padding = 6
        cells.size = 12
        column(0).size = 10
        cells.border_width = 0.1
        cells.valign = :center
        columns(2..-1).align = :center
        self.header = true
        columns = Array.new(masu_orders.length){60}
        self.column_widths = [250,130].push(columns).flatten!
      end

    end
  end
  def line_item_rows(products_num_h,date,total)
    data = [["お弁当","省略名","個数"]]
    products_num_h.each do |pnh|
      product_id = pnh[0]
      number = pnh[1]
      product = Product.find(product_id)
      data << [product.name,product.short_name,number]
    end
    data
  end
  def line_item_rows2(products_num_h,date,masu_orders)
    hash = {}
    MasuOrderDetail.where(masu_order_id:masu_orders.ids).each do |mso|
      hash.store([mso.masu_order_id,mso.product_id], mso.number)
    end
    kurumesi_ids = masu_orders.map{|masu_order| masu_order.kurumesi_order_id}
    data = [["お弁当","オーダーID▶"].push(kurumesi_ids).flatten!]
    data << ["","ピックアップ"].push(masu_orders.map{|mo|mo.pick_time.strftime("%R")}).flatten!
    product_ids = products_num_h.keys
    products = Product.where(id:product_ids)

    products.each do |product|
      arr = [product.name,product.short_name]
      masu_orders.each do |masu_order|
        arr.push(hash[[masu_order.id,product.id]])
      end
      data << arr.map {|e| e ? e : ''}
    end
    total_num = ['','合計']
    masu_orders.each do |masu_order|
      total_num.push(masu_order.number)
    end
    data << total_num
    data
  end
  def sen
    stroke_axis
  end
end
