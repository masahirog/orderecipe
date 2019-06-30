class MasuOrderLoadingSheetPdf < Prawn::Document
  def initialize(date,masu_orders,masu_orders_num_h,products_num_h)
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    font "vendor/assets/fonts/ipaexm.ttf"
    masu_orders_arr = masu_orders.each_slice(7).to_a
    masu_orders_arr.each_with_index do |moa,i|
      table_content(date,moa,masu_orders_num_h,products_num_h)
      start_new_page unless i + 1 == masu_orders_arr.length
    end
  end

  def table_content(date,moa,masu_orders_num_h,products_num_h)
    bounding_box([0, 570], :width => 820) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:9,:align => :right
      move_down 5
      table line_item_rows2(date,moa,masu_orders_num_h,products_num_h) do
        row(0..1).background_color = 'f5f5f5'
        cells.padding = [8,6,8,6]
        cells.size = 9
        cells.border_width = 0.1
        cells.valign = :center
        columns(1).size = 10
        row(0..1).columns(0).size = 10
        columns(2..-1).align = :center
        self.header = true
        columns = Array.new(moa.length){65}
        self.column_widths = [230,100].push(columns).flatten!
      end
    end
  end
  def line_item_rows2(date,moa,masu_orders_num_h,products_num_h)
    moa_ids = moa.map{|mo|mo.id}
    hash = {}
    MasuOrderDetail.where(masu_order_id:moa_ids).each do |mso|
      hash.store([mso.masu_order_id,mso.product_id], mso.number)
    end
    hash2 = {}
    moa.each do |mo|
      if mo.payment == '請求書'
        seikyusho = "◯"
        ryoshusho = ""
      else
        seikyusho = ""
        ryoshusho = "◯"
      end
      hash2.store(mo.id,[masu_orders_num_h[mo.id]+1,masu_orders_num_h[mo.id]+1,'◯','◯',seikyusho,ryoshusho])
    end

    kurumesi_ids = moa.map do |masu_order|
      if masu_order.memo.present?
        "#{masu_order.kurumesi_order_id} ★memo★"
      else
        masu_order.kurumesi_order_id
      end
    end

    data = [["配達日： #{date}","オーダーID▶"].push(kurumesi_ids).flatten!]
    arr2 = ['','ピックアップ時間']
    moa.each do |masu_order|
      if masu_order.pick_time.present?
        arr2.push(masu_order.pick_time.strftime("%R"))
      else
        arr2.push("")
      end
    end
    data << arr2
    product_ids = products_num_h.keys
    products = Product.where(id:product_ids).order('product_category ASC')

    products.each do |product|
      arr = [product.name.truncate(28),product.short_name]
      moa.each do |masu_order|
        arr.push(hash[[masu_order.id,product.id]])
      end
      data << arr.map {|e| e ? e : ''}
    end

    [['おしぼり','オシボリ'],['お箸','オハシ'],['保冷剤','ホレイザイ'],['納品書','ノウヒンショ'],['請求書','セイキュウショ'],['領収書','リョウシュウショ']].each_with_index do |yoso,i|
      arr = [yoso[0],yoso[1]]
      moa.each do |masu_order|
        arr.push(hash2[masu_order.id][i])
      end
      data << arr
    end
    data
  end
  def sen
    stroke_axis
  end
end
