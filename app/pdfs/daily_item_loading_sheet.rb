class DailyItemLoadingSheet < Prawn::Document
  def initialize(date,daily_items,stores,buppan_schedule)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"

    hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    daily_items.each do |di|
      di.daily_item_stores.each do |dis|
        if dis.subordinate_amount == 0
          hash[di.id][dis.store_id] = ''
        else
          hash[di.id][dis.store_id] = dis.subordinate_amount
        end
      end
    end

    table_content(date,daily_items,hash,stores,buppan_schedule)
  end

  def table_content(date,daily_items,hash,stores,buppan_schedule)
    bounding_box([10, 800], :width => 560) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
      text "#{date}仕訳表"
      move_down 10
      text "仕分け備考：",size:10
      move_down 5
      text "#{buppan_schedule.memo}",size:9
      move_down 10
      table line_item_rows(daily_items,hash) do
        self.row_colors = ["FFFFFF","E5E5E5"]
        # cells.padding = 6
        cells.size = 7
        # columns(1).size = 10
        # row(0..1).columns(0).size = 10
        cells.border_width = 0.1
        # cells.valign = :center
        # columns(-2).align = :center
        self.header = true
        self.column_widths = [30,120,120,40,40,40,40,40,40]
      end
      sorting_memo_index = 1
      daily_items.each do |di|
        if di.sorting_memo.present?
          memo = "※ #{sorting_memo_index}：#{di.sorting_memo}"
          sorting_memo_index += 1
          move_down 5
          text memo,size:9
        end
      end

      stores.each do |store|
        store_amount = hash.values.sum { |data| data[store.id].to_i}
        if store_amount > 0
          start_new_page
          text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
          text "#{date} ｜ #{store.name}納品書"        
          move_down 10
          table delivery_slip_line_item_rows(daily_items,hash,store) do
            self.row_colors = ["FFFFFF","E5E5E5"]
            # cells.padding = 6
            cells.size = 7
            # columns(1).size = 10
            # row(0..1).columns(0).size = 10
            cells.border_width = 0.1
            # cells.valign = :center
            # columns(-2).align = :center
            self.header = true
            self.column_widths = [200,200,100]
          end
        end
      end
    end
  end

  def line_item_rows(daily_items,hash)
    data = [["メモ","生産者","商品","合計","東中野","新中野","新高円寺","沼袋","荻窪","キッチン"]]
    sorting_memo_index = 1
    sorting_memo = 
    daily_items.each do |di|
      if di.sorting_memo.present?
        memo_flag = "※ #{sorting_memo_index}"
        sorting_memo_index += 1
      else
        memo_flag = ""
      end
      data << [memo_flag,"#{di.item.item_vendor.id} #{di.item.item_vendor.store_name}","#{di.item.name} #{di.item.variety}","#{di.delivery_amount} #{di.unit}",
                hash[di.id][9],hash[di.id][19],hash[di.id][29],hash[di.id][154],hash[di.id][164],hash[di.id][39]]
    end
    data
  end

  def delivery_slip_line_item_rows(daily_items,hash,store)
    data = [["生産者","商品","納品数"]]
    daily_items.each do |di|
      data << ["#{di.item.item_vendor.id} #{di.item.item_vendor.store_name}","#{di.item.name} #{di.item.variety}",hash[di.id][store.id]]
    end
    data
  end

end
