require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(product_id product_name product_cost menu_id menu_name cook_the_day_before serving_memo material_id material_name amount_used unit used_cost preparation post vendor)
  csv << csv_column_names
    menus = @product.menus
    menus.each_with_index do |menu,i|
      menu.menu_materials.each_with_index do |mm,ii|
        if i == 0 && ii == 0
          csv_column_values = [
            @product.id,
            @product.name,
            @product.cost_price,
            menu.id,
            menu.name,
            menu.cook_the_day_before,
            menu.serving_memo,
            mm.material_id,
            mm.material.name,
            mm.amount_used,
            mm.material.recipe_unit,
            (mm.amount_used * mm.material.cost_price).round(1),
            mm.preparation,
            mm.post,
            mm.material.vendor.name
          ]
          csv << csv_column_values
        elsif ii == 0
          csv_column_values = [
            "",
            "",
            "",
            "",
            menu.id,
            menu.name,
            menu.cook_the_day_before,
            menu.serving_memo,
            mm.material_id,
            mm.material.name,
            mm.amount_used,
            mm.material.recipe_unit,
            (mm.amount_used * mm.material.cost_price).round(1),
            mm.preparation,
            mm.post,
            mm.material.vendor.name
          ]
          csv << csv_column_values
        else
          csv_column_values = [
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            mm.material_id,
            mm.material.name,
            mm.amount_used,
            mm.material.recipe_unit,
            (mm.amount_used * mm.material.cost_price).round(1),
            mm.preparation,
            mm.post,
            mm.material.vendor.name
          ]
          csv << csv_column_values
        end
      end
    end
  end
