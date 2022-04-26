class SourcesPdf < Prawn::Document
  def initialize(from,to,controler)

    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape)
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    # daily_menu = DailyMenu.find_by(start_time:date)
    daily_menus = DailyMenu.where(start_time:from..to)
    daily_menu_details = DailyMenuDetail.includes([:daily_menu]).where(daily_menu_id:daily_menus.ids)
    hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    daily_menu_details.each do |dmd|
      hash[dmd.product_id][dmd.daily_menu.start_time] = dmd.manufacturing_number
    end
    hash.each_with_index do |data,i|
      product = Product.find(data[0])
      menus = product.menus
      dates_num = data[1]
      table_content(menus,dates_num,product)
      start_new_page if i<hash.count-1
    end
  end

  def table_content(menus,dates_num,product)
    bounding_box([-15, 540], :width => 800) do
      table line_item_rows(menus,dates_num,product) do
        cells.leading = 2
        cells.borders = [:bottom]
        cells.border_width = 0.2
        column(2).align = :right
        column(3).align = :center
        row(0).border_width = 1
        row(0).size = 9
        column(-1).size = 7
        self.header = true
        row_count = [80]*dates_num.count
        self.column_widths = [100,40,140,50,row_count,150].flatten
        grayout = []
        menuline = []
        values = cells.columns(1).rows(1..-1)
        values.each do |cell|
          grayout << cell.row unless cell.content == 'タレ'
        end
        grayout.each do |num|
          row(num).column(1..-1).background_color = "dcdcdc"
          row(num).column(2..-2).size = 8
        end
      end
    end
  end
  def line_item_rows(menus,dates_num,product)
    row_0 = []
    dates_num.each do |date_num|
      date = date_num[0].strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[date_num[0].wday]})")
      num = date_num[1]
      row_0 << "#{date}\n#{num}人"
    end
    data= [[{:content => "商品名：#{product.name}",colspan:3},"グループ",row_0,"仕込み内容"].flatten]
    menus.includes(:materials).each do |menu|
      u = menu.materials.length
      menu.menu_materials.each_with_index do |mm,i|
        if menu.category == "容器"
        else
          if mm.post == 'タレ'
            preparation = mm.preparation
          else
            preparation = ''
          end

          amount_data = []
          dates_num.each do |date_num|
            num = date_num[1]
            amount_data << "#{ActiveSupport::NumberHelper.number_to_rounded((mm.amount_used * num.to_i), strip_insignificant_zeros: true, :delimiter => ',', precision: 1)} #{mm.material.recipe_unit}"
          end
          if i == 0
            data << [{:content => "#{menu.name}", :rowspan => u, size: 9},
              {:content => "#{mm.post.slice(0..3)}", size: 7 },
              {:content => "#{mm.material.name}", size: 8 },
              {:content => "#{mm.source_group}", size:9,:align => :center },
              amount_data,
              {:content => "#{preparation}", size:7 }].flatten
          else
            data << [{:content => "#{mm.post.slice(0..3)}", size: 7 },
              {:content => "#{mm.material.name}", size: 9 },
              {:content => "#{mm.source_group}", size:9,:align => :center },
              amount_data,
              {:content => "#{preparation}", size: 7 }].flatten
          end

        end
      end
    end
    data
  end

  def sen
    stroke_axis
  end
end
