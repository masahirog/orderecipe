class CutList < Prawn::Document
  def initialize(bentos_num_h,date)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:10
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    menu_num_hash = {}
    bentos_num_h.each do |prnm|
      product = Product.find(prnm[0])
      num = prnm[1]
      product.menus.each do |menu|
        if menu_num_hash[menu.id].present?
          menu_num_hash[menu.id] += num
        else
          menu_num_hash[menu.id] = num
        end
      end
    end
    material_cut_hash = {}
    menu_num_hash.each do |menu_id,num|
      menu = Menu.find(menu_id)
      num = num
      menu_materials = menu.menu_materials.includes(:material).where(:materials => {measurement_flag:true})
      menu_materials.each do |mm|
        if mm.material_cut_pattern_id.present?
          amount = mm.amount_used * num
          if material_cut_hash[mm.material_cut_pattern_id].present?
            material_cut_hash[mm.material_cut_pattern_id][0] += amount
            material_cut_hash[mm.material_cut_pattern_id][2] += 1
            material_cut_hash[mm.material_cut_pattern_id][3] << [mm,num]
          else
            count = 1
            material_cut_hash[mm.material_cut_pattern_id] = [amount,mm.material.name,count,[[mm,num]]]
          end
        end
      end
    end
    table_content(material_cut_hash)
    page_count.times do |i|
      unless i < 0
        go_to_page(i+1)
        bounding_box([bounds.right-200, bounds.top - 5], :width => 185) {
          text "#{date.strftime("%-m/%d (#{%w(日 月 火 水 木 金 土)[date.wday]})")} 製造分　枚数：#{i+ 1 -0} / #{page_count - 0}",size:9,:align =>:right
        }
        bounding_box([bounds.right-200, 15], :width => 190) {
          text "印刷：#{Time.now.strftime("%Y-%m-%d %H:%M")}",size:9,:align =>:right
        }
      end
    end
  end

  def table_content(material_cut_hash)
    table line_item_rows(material_cut_hash) do
      self.row_colors = ["f5f5f5", "FFFFFF"]
      cells.padding = 6
      cells.size = 8
      cells.border_width = 0.1
      cells.valign = :center
      column(3).align = :right
      column(5).align = :right
      columns(4).size = 6
      columns(6).size = 7
      row(0).size = 8
      row(0).column(2).align = :left
      self.header = true
      self.column_widths = [25,120,150,50,150,50,270]
    end
  end

  def line_item_rows(material_cut_hash)
    data = [["","",'カット',"分量",'メニュー名','量',"仕込み"]]
    material_cut_hash = material_cut_hash.sort { |a, b| a[1][1] <=> b[1][1]}
    i = 0
    material_cut_hash.each do |mch|
      i += 1
      amount = ActiveSupport::NumberHelper.number_to_rounded(mch[1][0], strip_insignificant_zeros: true, :delimiter => ',', precision: 1)
      material_cut_pattern = MaterialCutPattern.find(mch[0])
      material = material_cut_pattern.material
      rowspan = mch[1][2]
      mch[1][3].each_with_index do |mm,index|
        menu_amount = ActiveSupport::NumberHelper.number_to_rounded((mm[0].amount_used * mm[1]), strip_insignificant_zeros: true, :delimiter => ',', precision: 1)
        if index == 0
          data << [{:content => "#{i}" , :rowspan => rowspan},{:content => material.name, :rowspan => rowspan},{:content => material_cut_pattern.name, :rowspan => rowspan},{:content =>"#{amount} #{material.recipe_unit}", :rowspan => rowspan},"#{mm[0].menu.name}(#{mm[1]})","#{menu_amount} #{material.recipe_unit}",mm[0].preparation]
        else
          data <<["#{mm[0].menu.name}(#{mm[1]})","#{menu_amount} #{material.recipe_unit}",mm[0].preparation]
        end
      end
    end
    data
  end
end
