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
    bounding_box([10, 800], :width => 560) do
      daily_menu = DailyMenu.find(daily_menu_id)
      text "発行時間：#{Time.now.strftime("%Y年 %m月 %d日　%H:%M")}",size:10,:align => :right
      text "#{daily_menu.start_time} べじはん製造"
      move_down 10
      table line_item_rows(daily_menu) do
        self.row_colors = ["FFFFFF","E5E5E5"]
        # cells.padding = 6
        cells.size = 7
        # columns(1).size = 10
        # row(0..1).columns(0).size = 10
        cells.border_width = 0.1
        # cells.valign = :center
        columns(-2).align = :center
        self.header = true
        self.column_widths = [180,50,50,50,50,50,50,50]
      end
    end
  end

  def line_item_rows(daily_menu)
    data = [['商品名','製造合計','東中野','高円寺','朝調理','追加在庫','残（冷凍）','完売']]
    daily_menu_details = DailyMenuDetail.joins(:product).order(:row_order).where(daily_menu_id:daily_menu.id)
    sdmd_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    store_daily_menu_idhash = {}
    daily_menu.store_daily_menus.includes(:store_daily_menu_details).each do |sdm|
      store_daily_menu_idhash[sdm.store_id] = sdm.id
      sdm.store_daily_menu_details.each do |sdmd|
        sdmd_hash[sdm.store_id][sdmd.product_id] = sdmd.number
      end
    end

    daily_menu_details.each do |dmd|
      if sdmd_hash[9][dmd.product_id].present?
        if sdmd_hash[9][dmd.product_id] == 0
          nakano = ""
        else
          nakano = sdmd_hash[9][dmd.product_id]
        end
      else
        nakano = ""
      end
      if sdmd_hash[19][dmd.product_id].present?
        if sdmd_hash[19][dmd.product_id] == 0
          koenji = ""
        else
          koenji = sdmd_hash[19][dmd.product_id]
        end
      else
        koenji = ""
      end

      if dmd.product.carryover_able_flag == true
        morning_number = "※　" + (nakano/2.0).ceil.to_s
        data << [dmd.product.name,dmd.manufacturing_number,nakano,koenji,morning_number,'','','']
      else
        data << [dmd.product.name,dmd.manufacturing_number,nakano,koenji,nakano,'','ー','']
      end
    end
    data
  end
end
