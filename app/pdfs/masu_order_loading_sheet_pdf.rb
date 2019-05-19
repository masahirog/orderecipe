class MasuOrderLoadingSheetPdf < Prawn::Document
  def initialize(products_num_h,date)
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    font "vendor/assets/fonts/ipaexm.ttf"
    table_content(products_num_h,date)
  end

  def table_content(products_num_h,date)
    masu_orders = MasuOrder.where(start_time:date)
    total = products_num_h.values.inject(:+)

    bounding_box([20, 550], :width => 840) do
      table line_item_rows2(products_num_h,date,masu_orders,total) do
        row(0).background_color = 'f5f5f5'
        cells.padding = [8,6,8,6]
        cells.size = 10
        cells.border_width = 0.1
        cells.valign = :center
        columns(2..-1).align = :center
        self.header = true
        columns = Array.new(masu_orders.length){60}
        self.column_widths = [280,130].push(columns).flatten!
      end
    end
  end
  def line_item_rows2(products_num_h,date,masu_orders,total)

    hash = {}
    MasuOrderDetail.where(masu_order_id:masu_orders.ids).each do |mso|
      hash.store([mso.masu_order_id,mso.product_id], mso.number)
    end
    hash2 = {}
    masu_orders.each do |mo|
      if mo.miso == "あり"
        miso = mo.number
      else
        miso = ''
      end
      if mo.trash_bags == 0
        trash_bags = ""
      else
        trash_bags = mo.trash_bags
      end
      if mo.payment == '請求書'
        seikyusho = "◯"
        ryoshusho = ""
      else
        seikyusho = ""
        ryoshusho = "◯"
      end
      if mo.tea == "不要"
        tea = ""
      elsif mo.tea == 'PET'
        tea = "PET：#{mo.number}"
      else
        tea = "缶：#{mo.number}"
      end
      hash2.store(mo.id,[mo.number,mo.number,miso,miso,tea,trash_bags,'◯','◯',seikyusho,ryoshusho])
    end

    kurumesi_ids = masu_orders.map{|masu_order| masu_order.kurumesi_order_id}

    data = [["配達日： #{date}　　　　お弁当合計：　#{total} 個","オーダーID▶"].push(kurumesi_ids).flatten!]

    product_ids = products_num_h.keys
    products = Product.where(id:product_ids)

    products.each do |product|
      arr = [product.name,product.short_name]
      masu_orders.each do |masu_order|
        arr.push(hash[[masu_order.id,product.id]])
      end
      data << arr.map {|e| e ? e : ''}
    end

    [['おしぼり','オシボリ'],['お箸','オハシ'],['みそ汁','ミソシル'],['紙コップ','カミコップ'],['お茶','オチャ'],['保冷剤','ホレイザイ'],['ごみ袋','ゴミブクロ'],['納品書','ノウヒンショ'],['請求書','セイキュウショ'],['領収書','リョウシュウショ']].each_with_index do |yoso,i|
      arr = [yoso[0],yoso[1]]
      masu_orders.each do |masu_order|
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
