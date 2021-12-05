require 'csv'
bom = "\uFEFF"
CSV.generate(bom) do |csv|
  csv_column_names = %w(日付 名称 分類 追加)
  csv << csv_column_names
  menu_ids = []
  @products_num_h.each do |productid_num|
    num = productid_num[1]
    product = Product.find(productid_num[0])
    product.menus.each do |menu|
      hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
      if menu_ids.include?(menu.id)
      else
        menu.menu_materials.each do |mm|
          if mm.source_group.present?
            if hash[mm.source_group].present?
              if mm.post == 'タレ'
              else
                hash[mm.source_group]['add'] = "当日追加調味料あり"
              end
            else
              hash[mm.source_group]['date'] = @date
              hash[mm.source_group]['menu_name'] = menu.short_name
              if mm.post == 'タレ'
                hash[mm.source_group]['add'] = ''
              else
                hash[mm.source_group]['add'] = "当日追加調味料あり"
              end
            end
          end
        end
        menu_ids << menu.id
      end
      hash.each do |data|
        source_group = data[0]
        date = data[1]['date']
        menu_name = data[1]['menu_name']
        add = data[1]['add']
        csv << [date,menu_name,source_group,add]
      end
    end
  end
end
