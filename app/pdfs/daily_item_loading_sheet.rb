class DailyItemLoadingSheet < Prawn::Document
  def initialize(date,daily_items)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(date,daily_items)
  end

  def table_content(date,daily_items)
    bounding_box([10, 800], :width => 560) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:8,:align => :right
      text "#{date}仕訳表"
      move_down 10
      table line_item_rows(daily_items) do
        self.row_colors = ["FFFFFF","E5E5E5"]
        # cells.padding = 6
        cells.size = 7
        # columns(1).size = 10
        # row(0..1).columns(0).size = 10
        cells.border_width = 0.1
        # cells.valign = :center
        # columns(-2).align = :center
        self.header = true
        self.column_widths = [130,100,50,50,50,50,50,50]
      end
    end
  end

  def line_item_rows(daily_items)

    data = [["生産者","商品","合計","東中野店","新中野店","新高円寺店","沼袋店","荻窪店","キッチン"]]
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
    daily_items.each do |di|
      data << ["#{di.item.item_vendor.id} #{di.item.item_vendor.store_name}","#{di.item.name} #{di.item.variety}","#{di.delivery_amount} #{di.unit}",
                hash[di.id][9],hash[di.id][19],hash[di.id][29],hash[di.id][154],hash[di.id][164],hash[di.id][39]]
    end
    data
  end
end
