require 'csv'
bom = "\uFEFF"
CSV.generate(bom) do |csv|
  csv_column_names = %w(日付 名称 分類 追加)
  csv << csv_column_names
  @daily_menus.each do |daily_menu|
    daily_menu.daily_menu_details.each do |dmd|
      num = dmd.manufacturing_number
      dmd.product.product_menus.each do |pm|
        hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
        pm.menu.menu_materials.each do |mm|
          if mm.source_group.present?
            if hash[mm.source_group].present?
              if mm.post == 'タレ'
              else
                amount = (num * mm.amount_used).round(1)
                if hash[mm.source_group]['add'].present?
                  hash[mm.source_group]['add'] << "｜#{mm.material.short_name}：#{amount}#{mm.material.recipe_unit}"
                else
                  hash[mm.source_group]['add'] << "#{mm.material.short_name}：#{amount}#{mm.material.recipe_unit}"
                end
              end
            else
              hash[mm.source_group]['date'] = daily_menu.start_time.strftime("%-m/%-d")
              hash[mm.source_group]['menu_name'] = pm.menu.short_name
              if mm.post == 'タレ'
                hash[mm.source_group]['add'] = ''
              else
                amount = (num * mm.amount_used).round(1)
                hash[mm.source_group]['add'] = "#{mm.material.short_name}：#{amount}#{mm.material.recipe_unit}"
              end

            end
          end
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
end
