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
        # columns(2..-1).align = :center
        self.header = true
        self.column_widths = [180,50,50,50,50,50,50]
      end
    end
  end

  def line_item_rows(daily_menu)
    data = [['商品名','製造合計','東中野','高円寺','追加分','朝調理','追加調理','翌日繰越']]
    daily_menu_details = DailyMenuDetail.joins(:product).order("products.carryover_able_flag DESC").order(:row_order).where(daily_menu_id:daily_menu.id)
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
        nakano = sdmd_hash[9][dmd.product_id]
      else
        nakano = 0
      end
      if sdmd_hash[19][dmd.product_id].present?
        koenji = sdmd_hash[19][dmd.product_id]
      else
        koenji = 0
      end

      if dmd.product.carryover_able_flag == true
        data << [dmd.product.name,dmd.manufacturing_number,nakano,koenji,'','','','']
      else
        data << [dmd.product.name,dmd.manufacturing_number,nakano,koenji,'',dmd.manufacturing_number,'','']
      end
    end
    data
  end
end
