class CollationOnly < Prawn::Document
  def initialize(date,kurumesi_orders)
    super(
      page_size: 'A4',
      page_layout: :portrait,
      margin:10
    )
    font "vendor/assets/fonts/ipaexg.ttf"
    i = 0
    kurumesi_orders.each do |ko|
      table_content(date,ko)
      i += 1
      start_new_page unless i == kurumesi_orders.length
    end
  end


  def table_content(date,ko)
    bounding_box([40, 750], :width => 490) do
      text "受注番号：#{ko.management_id}",:align => :right
      move_down 5
      text "納品日：#{ko.start_time.strftime("%Y年 %m月 %d日")}",:align => :right
      move_down 20
      text "納品書",:align => :center,:size => 20
      move_down 30
      text "この度はご注文頂きまして、誠にありがとうございます。"
      move_down 3
      text "以下の通り納品させていただきましたので、ご確認ください。"
      move_down 20
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
      move_down 20
      text "またのご利用を心よりお待ちしております。",:align => :right
      move_down 10
      text "#{ko.brand.name}",:align => :right
      move_down 20
      bounding_box([0, 0], width: 500, height: 110) do
        transparent(0.8) { stroke_bounds }
        font_size 12
        bounding_box([15, 100], width: 400, height: 90) do
          text "◇◆口コミ投稿で、Amazonポイントプレゼント◆◇",:align => :center,size:14
          move_down 8
          font_size 11
          text "くるめし弁当ではお弁当納品後にマイページから、口コミタイトル＆コメントを投稿して頂いたお客様限定に、amazonギフト券をプレゼントするキャンペーン中です！ぜひご感想をお聞かせください。", leading: 3
          move_down 5
          text "※口コミ投稿有効期限は納品後から30日以内となります。",size:10
        end
        bounding_box([430, 90], width: 80, height: 100) do
          image 'app/assets/images/kurumesi_mypage.png', at: [0, 100], width: 60
          move_down 60
          text "　くるめし弁当",size:8
          text "　マイページへ",size:8
        end
      end

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
