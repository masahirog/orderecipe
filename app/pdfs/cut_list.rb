class CutList < Prawn::Document
  def initialize(bentos_num_h,date,list_pattern)
    # 初期設定。ここでは用紙のサイズを指定している。
    super(
      page_size: 'A4',
      page_layout: :landscape,
      margin:[25,10,10,10]
    )
    #日本語のフォント
    font "vendor/assets/fonts/ipaexg.ttf"
    menu_num_hash = {}
    bentos_num_h.each do |prnm|
      product = Product.find(prnm[0])
      num = prnm[1][0]
      product.menus.each do |menu|
        if menu_num_hash[menu.id].present?
          menu_num_hash[menu.id][0] += num
        else
          menu_num_hash[menu.id] = [num,prnm[1][1]]
        end
      end
    end
    material_cut_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    machine_cut_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    menu_num_hash.each do |menu_id,num_brand|
      menu = Menu.find(menu_id)
      num = num_brand[0]
      brand = num_brand[1]
      menu_materials = menu.menu_materials.includes(:material,:menu).where(:materials => {measurement_flag:true})
      menu_materials.each do |mm|
        if mm.material_cut_pattern_id.present?
          amount = mm.amount_used * num
          # 一時的な食材変更があるかどうか？
          tmm = mm.temporary_menu_materials.find_by(date:date)
          if tmm.present?
            material_id = tmm.material_id
            material_name = tmm.material.name
          else
            material_id = mm.material_id
            material_name = mm.material.name
          end
          if mm.material_cut_pattern.machine.present?
            if machine_cut_hash[material_id][mm.material_cut_pattern_id].present?
              machine_cut_hash[material_id][mm.material_cut_pattern_id][0] += amount
              machine_cut_hash[material_id][mm.material_cut_pattern_id][2] += 1
              machine_cut_hash[material_id][mm.material_cut_pattern_id][3] << [mm,num,brand]
            else
              count = 1
              machine_cut_hash[material_id][mm.material_cut_pattern_id] = [amount,material_name,count,[[mm,num,brand]]]
            end

          else
            if material_cut_hash[material_id][mm.material_cut_pattern_id].present?
              material_cut_hash[material_id][mm.material_cut_pattern_id][0] += amount
              material_cut_hash[material_id][mm.material_cut_pattern_id][2] += 1
              material_cut_hash[material_id][mm.material_cut_pattern_id][3] << [mm,num,brand]
            else
              count = 1
              material_cut_hash[material_id][mm.material_cut_pattern_id] = [amount,material_name,count,[[mm,num,brand]]]
            end
          end
        end
      end
    end
    if list_pattern == "0"
      table_content(material_cut_hash)
      page_count.times do |i|
        unless i < 0
          go_to_page(i+1)
          bounding_box([340,575], :width => 450) {
            text "切出リスト #{date.strftime("%-m/%d (#{%w(日 月 火 水 木 金 土)[date.wday]})")} 製造分　枚数：#{i+ 1 -0} / #{page_count - 0}　　印刷：#{Time.now.strftime("%Y-%m-%d %H:%M")}",size:9,:align =>:right
          }
        end
      end
      min = page_count
      start_new_page
      table_content(machine_cut_hash)
      page_count.times do |i|
        unless i < min
          go_to_page(i+1)
          bounding_box([340,575], :width => 450) {
            text "機械リスト #{date.strftime("%-m/%d (#{%w(日 月 火 水 木 金 土)[date.wday]})")} 製造分　枚数：#{i+ 1 -0 -min} / #{page_count - 0 -min}　　印刷：#{Time.now.strftime("%Y-%m-%d %H:%M")}",size:9,:align =>:right
          }
        end
      end

    elsif list_pattern == "1"
      table_content(material_cut_hash)
      page_count.times do |i|
        unless i < 0
          go_to_page(i+1)
          bounding_box([340,575], :width => 450) {
            text "切出リスト #{date.strftime("%-m/%d (#{%w(日 月 火 水 木 金 土)[date.wday]})")} 製造分　枚数：#{i+ 1 -0} / #{page_count - 0}　　印刷：#{Time.now.strftime("%Y-%m-%d %H:%M")}",size:9,:align =>:right
          }
        end
      end
    elsif list_pattern == "2"
      table_content(machine_cut_hash)
      page_count.times do |i|
        unless i < 0
          go_to_page(i+1)
          bounding_box([340,575], :width => 450) {
            text "機械リスト #{date.strftime("%-m/%d (#{%w(日 月 火 水 木 金 土)[date.wday]})")} 製造分　枚数：#{i+ 1 -0} / #{page_count - 0}　　印刷：#{Time.now.strftime("%Y-%m-%d %H:%M")}",size:9,:align =>:right
          }
        end
      end
    end
  end

  def table_content(material_cut_hash)
    table line_item_rows(material_cut_hash) do
      grayout = []
      cells.padding = 6
      cells.size = 8
      cells.border_width = 0.1
      cells.valign = :center
      column(0).leading = 4
      column(1).align = :right
      column(3).align = :right
      columns(-1).size = 6
      row(0).size = 8
      values = cells.columns(5).rows(1..-1)
      values.each do |cell|
        grayout << cell.row if cell.content.include?("★")
      end
      grayout.map{|num|row(num).column(3..-1).background_color = "dcdcdc"}
      self.header = true
      self.column_widths = [140,55,170,50,220,30,150]
    end
  end

  def line_item_rows(material_cut_hash)
    data = [["","分量",'カット','量',"仕込み",'変更','']]
    material_cut_hash.each do |mmch|
      material_rowspan = 0
      material_used_total_amount = 0
      mmch[1].each do |mch|
        material_rowspan += mch[1][2]
        material_used_total_amount += mch[1][0]
      end
      material_used_total_amount = ActiveSupport::NumberHelper.number_to_rounded(material_used_total_amount, strip_insignificant_zeros: true, :delimiter => ',', precision: 1)
      mmch[1].each_with_index do |mch,i|
        amount = ActiveSupport::NumberHelper.number_to_rounded(mch[1][0], strip_insignificant_zeros: true, :delimiter => ',', precision: 1)
        material_cut_pattern = MaterialCutPattern.find(mch[0])
        default_material = material_cut_pattern.material
        material_name = mch[1][1]
        rowspan = mch[1][2]
        if mmch[0] == default_material.id
          chage_flag = ""
        else
          chage_flag = "◯"
        end
        mch[1][3].each_with_index do |mm,index|
          menu_amount = ActiveSupport::NumberHelper.number_to_rounded((mm[0].amount_used * mm[1]), strip_insignificant_zeros: true, :delimiter => ',', precision: 1)
          if mm[2]=='kurumesi'
            flag = '★'
          else
            flag = ''
          end
          if index == 0
            if i == 0
              if mmch[1].count > 1
                data << [{:content => "#{material_name}\n【 計：#{material_used_total_amount} #{default_material.recipe_unit} 】", :rowspan => material_rowspan},{:content =>"#{amount} #{default_material.recipe_unit}", :rowspan => rowspan},{:content => material_cut_pattern.name, :rowspan => rowspan},"#{menu_amount} #{default_material.recipe_unit}",mm[0].preparation,chage_flag,"#{flag} #{mm[0].menu.name}(#{mm[1]})"]
              else
                data << [{:content => "#{material_name}", :rowspan => material_rowspan},{:content =>"#{amount} #{default_material.recipe_unit}", :rowspan => rowspan},{:content => material_cut_pattern.name, :rowspan => rowspan},"#{menu_amount} #{default_material.recipe_unit}",mm[0].preparation,chage_flag,"#{flag} #{mm[0].menu.name}(#{mm[1]})"]
              end
            else
              data <<[{:content =>"#{amount} #{default_material.recipe_unit}", :rowspan => rowspan},{:content => material_cut_pattern.name, :rowspan => rowspan},"#{menu_amount} #{default_material.recipe_unit}",mm[0].preparation,chage_flag,"#{flag} #{mm[0].menu.name}(#{mm[1]})"]
            end
          else
            data <<["#{menu_amount} #{default_material.recipe_unit}",mm[0].preparation,chage_flag,"#{flag} #{mm[0].menu.name}(#{mm[1]})"]
          end
        end
      end
    end
    data
  end
end
