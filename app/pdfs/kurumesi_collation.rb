class KurumesiCollation < Prawn::Document
  def initialize(date,kurumesi_orders)
    super(
      page_size: 'A4',
      page_layout: :portrait,
      margin:10
    )
    font "vendor/assets/fonts/ipaexg.ttf"
    i = 0
    contents = []
    threads = kurumesi_orders.map{ |management_id,arr|
      Thread.new{
        contents << URI.open(arr[1])
      }
    }
    threads.each{ |thread|
      thread.join
    }
    kurumesi_orders.each do |management_id,arr|
      delivery_note(contents[i])
      start_new_page
      table_content(date,arr[0])
      i += 1
      start_new_page unless i == kurumesi_orders.length
    end
  end
  def delivery_note(content)
    move_down 10
    image content, at: [-20, 780], width: 620
  end

  def table_content(date,ko)
    bounding_box([40, 750], :width => 490) do
      text "受注番号：#{ko.management_id}",:align => :right
      move_down 5
      text "納品日：#{ko.start_time.strftime("%Y年 %m月 %d日")}",:align => :right
      move_down 20
      text "納品書",:align => :center,:size => 20
      move_down 40
      text "この度はご注文頂きまして、誠にありがとうございます。"
      move_down 3
      text "以下の通り納品させていただきましたので、ご確認ください。"
      move_down 30
      table line_item_rows(ko) do
        rows(0).background_color = "E5E5E5"
        cells.padding = [8,5,8,5]
        cells.border_width = 0.1
        cells.valign = :center
        cells.align = :right
        self.header = true
        self.column_widths = [330,100,60]
        columns(0).align = :left
      end
      move_down 40
      text "またのご利用を心よりお待ちしております。",:align => :right
      move_down 10
      text "#{ko.brand.name}",:align => :right
    end
  end
  def line_item_rows(ko)
    data = [['商品名','記号','個数']]
    ko.kurumesi_order_details.includes(:product).order("products.product_category").each do |kod|
      data << [kod.product.name,kod.product.symbol,kod.number]
    end
    data
  end
  def sen
    stroke_axis
  end
end
