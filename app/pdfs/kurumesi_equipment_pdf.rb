class KurumesiEquipmentPdf < Prawn::Document
  def initialize(date,kurumesi_orders,kurumesi_orders_num_h,products_num_h,brand_ids)
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    font "vendor/assets/fonts/ipaexg.ttf"
    text "配達日： #{date}"
    text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:9,:align => :right
    brand_ids.each_with_index do |brand_id,ii|
      brand_kurumesi_orders = kurumesi_orders.where(brand_id:brand_id)
      brand_product_ids = KurumesiOrderDetail.joins(:kurumesi_order).order('kurumesi_orders.pick_time').where(kurumesi_order_id:brand_kurumesi_orders.ids).map{|kod|kod.product_id}.uniq
      kurumesi_orders_arr = brand_kurumesi_orders.each_slice(10).to_a
      kurumesi_orders_arr.each_with_index do |moa,i|
        table_content(date,moa,kurumesi_orders_num_h,products_num_h,brand_id,brand_product_ids)
        move_down 10 unless i + 1 == kurumesi_orders_arr.length
      end
      move_down 10 unless ii + 1 == brand_ids.length
    end
  end

  def table_content(date,moa,kurumesi_orders_num_h,products_num_h,brand_id,brand_product_ids)
      brand_name = Brand.find(brand_id).name
      text brand_name
      move_down 5
      table line_item_rows2(date,moa,kurumesi_orders_num_h,products_num_h,brand_product_ids,brand_id) do
        row(0).background_color= "E5E5E5"
        cells.padding = [8,6,8,6]
        cells.size = 10
        cells.border_width = 0.1
        cells.valign = :center
        cells.align = :center
        self.header = true
        columns = Array.new(moa.length){65}
        self.column_widths = [95].push(columns).flatten!

      end
  end
  def line_item_rows2(date,moa,kurumesi_orders_num_h,products_num_h,brand_product_ids,brand_id)
    moa_ids = moa.map{|mo|mo.id}
    hash = {}
    KurumesiOrderDetail.where(kurumesi_order_id:moa_ids).each do |mso|
      hash.store([mso.kurumesi_order_id,mso.product_id], mso.number)
    end

    hash2 = {}
    moa.each do |mo|
      num = kurumesi_orders_num_h[mo.id]
      bihin = kurumesi_orders_num_h[mo.id]+1
      hashi = (4.2 * bihin).ceil(1)
      if brand_id == 21
        spoon = (2.2 * bihin).ceil(1)
        hash2.store(mo.id,["#{bihin}\n(#{hashi}g)",bihin,"#{bihin}\n(#{spoon}g)"])
      else
        hash2.store(mo.id,["#{bihin}\n(#{hashi}g)",bihin])
      end
    end
    kurumesi_ids = moa.map{|kurumesi_order|kurumesi_order.management_id.to_s[-5..-1]}
    data = [["品名"].push(kurumesi_ids).flatten!]
    if brand_id == 11
      arr = ["みそ汁"]
      moa.each do |kurumesi_order|
        arr.push(hash[[kurumesi_order.id,3831]])
      end
      data << arr.map {|e| e ? e : ''}
    end
    if brand_id == 21
      koumoku = [['はし(4.2g)'],['おしぼり'],['スプーン（2.2g）','スプーン']]
    else
      koumoku = [['はし(4.2g)'],['おしぼり']]
    end
    koumoku.each_with_index do |ar,i|
      arr = [ar[0]]
      moa.each do |kurumesi_order|
        arr.push(hash2[kurumesi_order.id][i])
      end
      data << arr
    end
    data
  end
  def sen
    stroke_axis
  end
end
