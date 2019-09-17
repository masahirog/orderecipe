require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(menu_id menu_name cook_the_day_before serving_memo material_id material_name amount_used unit used_cost preparation post vendor)
  csv << csv_column_names
    menu_materials = @menu.menu_materials
    menu_materials.each_with_index do |menu_material,i|
      if i==0
        csv_column_values = [
          @menu.id,
          @menu.name,
          @menu.cook_the_day_before,
          @menu.serving_memo,
          menu_material.material.id,
          menu_material.material.name,
          menu_material.amount_used,
          menu_material.material.recipe_unit,
          (menu_material.amount_used * menu_material.material.cost_price).round(1),
          menu_material.preparation,
          menu_material.post,
          menu_material.material.vendor.company_name
        ]
        csv << csv_column_values
      else
        csv_column_values = [
          '',
          '',
          '',
          '',
          menu_material.material.id,
          menu_material.material.name,
          menu_material.amount_used,
          menu_material.material.recipe_unit,
          (menu_material.amount_used * menu_material.material.cost_price).round(1),
          menu_material.preparation,
          menu_material.post,
          menu_material.material.vendor.company_name
        ]
        csv << csv_column_values
      end
    end
  end
