class DailyMenuPdf < Prawn::Document
  def initialize(daily_menu_id)
    super(
      page_size: 'A4',
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    table_content(daily_menu_id)
  end

  def table_content(daily_menu_id)
    daily_menu = DailyMenu.find(daily_menu_id)
    count = 0
    i = 0
    daily_menu.store_daily_menus.each do |sdm|
      number = sdm.store_daily_menu_details.sum(:number)
      count += 1 if number>0
    end      
    daily_menu.store_daily_menus.each_with_index do |sdm|
      num = sdm.store_daily_menu_details.sum(:number)
      if num > 0
        bounding_box([10, 800], :width => 560) do
          text " 納 品 書",:align => :center,:size => 20
          move_down 5
          text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:10,:align => :right
          text "#{sdm.store.name} 宛（#{sdm.start_time} 分）",size:15
          move_down 10
          table line_item_rows(sdm) do
            self.row_colors = ["FFFFFF","E5E5E5"]
            cells.size = 7
            cells.border_width = 0.1
            cells.align = :center
            columns(0).align = :left
            columns(-1).align = :left
            columns(-2).align = :center
            self.header = true
            self.column_widths = [180,50,30,30,50,30,170]
          end
          move_down 10

          rows = [['コンテナ','数','メモ'],['　','',''],['　','',''],['　','',''],['　','',''],['　','','']]
          table rows do
            self.column_widths = [180,50,200]
          end
          move_down 5
          text "その他メモ："
        end
        start_new_page if i < count + 1
        i += 1
      end
    end
  end

  def line_item_rows(sdm)
    total_sozai = 0
    total_fukusai = 0
    total_price = 0
    data = [['商品名','卸値','副菜','惣菜','小計','パーツ','詳細']]
    sdm.store_daily_menu_details.includes(product:[:product_parts]).each do |sdmd|
      product_parts = sdmd.product.product_parts
      if sdmd.bento_fukusai_number > 0
        fukusai_num = sdmd.bento_fukusai_number
      else
        fukusai_num = ""
      end
      if sdmd.sozai_number > 0
        sozai_number = sdmd.sozai_number
      else
        sozai_number = ""
      end
      num = (fukusai_num.to_i + sozai_number.to_i)
      oroshi_ne = (sdmd.product.sell_price*0.75).round
      syokei = ActiveSupport::NumberHelper.number_to_rounded(oroshi_ne * num, strip_insignificant_zeros: true, :delimiter => ',')
      total_sozai += sozai_number.to_i
      total_fukusai += fukusai_num.to_i
      total_price += oroshi_ne * num
      data << [sdmd.product.name,oroshi_ne,fukusai_num,sozai_number,syokei,product_parts.count,product_parts.map{|pp|pp.name.slice(0..5)}.join("｜")]
    end
    total_price = ActiveSupport::NumberHelper.number_to_rounded(total_price, strip_insignificant_zeros: true, :delimiter => ',')
    data << ["合　計","",total_fukusai,total_sozai,total_price,"",""]
    data
  end
end
