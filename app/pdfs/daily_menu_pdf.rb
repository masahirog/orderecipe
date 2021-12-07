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
    daily_menu.store_daily_menus.each_with_index do |sdm,i|
      bounding_box([10, 800], :width => 560) do
        text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:10,:align => :right
        text "#{sdm.start_time} #{sdm.store.name}"
        move_down 10
        table line_item_rows(sdm) do
          self.row_colors = ["FFFFFF","E5E5E5"]
          # cells.padding = 6
          cells.size = 7
          # columns(1).size = 10
          # row(0..1).columns(0).size = 10
          cells.border_width = 0.1
          # cells.valign = :center
          columns(-2).align = :center
          self.header = true
          self.column_widths = [180,50,50,80,50,50,50,50,50]
        end
        move_down 10

        rows = [
          ['コンテナ数','　　　'],
          ['　','　　　'],['　','　　　'],['　','　　　'],['　','　　　']
        ]
        table rows do
          self.column_widths = [180,50]
        end
        move_down 5
        text "その他メモ："
      end

      start_new_page if i < daily_menu.store_daily_menus.length - 1
    end
  end

  def line_item_rows(sdm)
    data = [['商品名','翌日繰越','冷凍保存','製造数（朝調理数）','追加調理','残（繰越）','完売']]
    sdm.store_daily_menu_details.each do |sdmd|
      if sdmd.product.carryover_able_flag == true
        kurikoshi = '○'
        morning_number = "（ #{(sdmd.number/1.4).ceil.to_s} ）"
      else
        kurikoshi = ''
        morning_number = ''
      end
      if sdmd.product.freezing_able_flag == true
        reito = '○'
      else
        reito = ''
      end
      data << [sdmd.product.name,kurikoshi,reito,"#{sdmd.number}#{morning_number}",'','','']
    end
    data
  end
end
