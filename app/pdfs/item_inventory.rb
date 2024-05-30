class ItemInventory < Prawn::Document
  def initialize(item_store_stocks)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(item_store_stocks)
  end

  def table_content(item_store_stocks)
    bounding_box([10, 800], :width => 560) do
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:10,:align => :right
      move_down 10
      table line_item_rows(item_store_stocks) do
        row(0).background_color = 'f5f5f5'
        cells.size = 8
        column(-2..-1).align = :right
        cells.border_width = 0.1
        self.header = true
        self.column_widths = [200,100,100,70,80]
      end
    end
  end

  def line_item_rows(item_store_stocks)
    data = [['商品名','仕入先','仕入れ値','在庫','在庫金額']]
    item_store_stocks.each do |iss|
      column_values = [iss.item.name,iss.item.item_vendor.store_name,"1#{iss.item.unit}：#{iss.item.purchase_price.to_s(:delimited)}円",iss.unit,
      "#{(iss.unit_price * iss.stock).to_i.to_s(:delimited)}円"]
      data << column_values

    end
    data
  end
end
