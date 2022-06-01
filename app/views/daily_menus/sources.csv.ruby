require 'csv'
bom = "\uFEFF"
CSV.generate(bom) do |csv|
  hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
  csv_column_names = %w(日付 名称 分類 追加)
  csv << csv_column_names
  @daily_menus.each do |daily_menu|
    daily_menu.daily_menu_details.includes([product:[menus:[menu_materials:[:material]]]]).each do |dmd|
      num = dmd.manufacturing_number
      dmd.product.menus.each do |menu|
        menu.menu_materials.each do |mm|
          if mm.source_group.present?
            if hash[daily_menu.id][menu.id][mm.source_group].present?
              if mm.post == 'タレ'
                hash[daily_menu.id][menu.id][mm.source_group]['source_flag'] = true
              else
                amount = (num * mm.amount_used).round(1)
                if hash[daily_menu.id][menu.id][mm.source_group]['add'][mm.id].present?
                  hash[daily_menu.id][menu.id][mm.source_group]['add'][mm.id]["amount"] += amount
                else
                  hash[daily_menu.id][menu.id][mm.source_group]['add'][mm.id]["amount"] = amount
                  hash[daily_menu.id][menu.id][mm.source_group]['add'][mm.id]["material_name"] = mm.material.short_name
                  hash[daily_menu.id][menu.id][mm.source_group]['add'][mm.id]["recipe_unit"] = mm.material.recipe_unit
                end
              end
            else
              hash[daily_menu.id][menu.id][mm.source_group]['source_flag'] = false #グループの中にタレの持ち場が1個も無いときは、シールのcsvでは出さない
              hash[daily_menu.id][menu.id][mm.source_group]['date'] = daily_menu.start_time.strftime("%-m/%-d")
              hash[daily_menu.id][menu.id][mm.source_group]['menu_name'] = menu.short_name
              if mm.post == 'タレ'
                hash[daily_menu.id][menu.id][mm.source_group]['source_flag'] = true
                # hash[daily_menu.id][menu.id][mm.source_group]['add'][mm.id]["amount"] = 0
              else
                amount = (num * mm.amount_used).round(1)
                hash[daily_menu.id][menu.id][mm.source_group]['add'][mm.id]["amount"] = amount
                hash[daily_menu.id][menu.id][mm.source_group]['add'][mm.id]["material_name"] = mm.material.short_name
                hash[daily_menu.id][menu.id][mm.source_group]['add'][mm.id]["recipe_unit"] = mm.material.recipe_unit
              end
            end
          end
        end
      end
    end
  end
  hash.each do |dm_data|
    dm_data[1].each do |menu_data|
      menu_data[1].each do |source_data|
        if source_data[1]['source_flag'] == true
          source_group = source_data[0]
          date = source_data[1]['date']
          menu_name = source_data[1]['menu_name']
          add_content = ''
          source_data[1]['add'].each do |add|
            add_content += "#{add[1]['material_name']}：#{add[1]['amount']}#{add[1]['recipe_unit']}"
          end
          csv << [date,menu_name,source_group,add_content]
        end
      end
    end
  end
end
