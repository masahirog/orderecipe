require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(product_id bento_id product_name product_cost menu_id menu_name material_id material_name amount_used unit used_cost)
  csv << csv_column_names
    menus = @product.menus
    menus.each_with_index do |menu,i|
      menu.menu_materials.order(:row_order).each_with_index do |mm,ii|
        if i == 0 && ii == 0
          csv_column_values = [
            @product.id,
            @product.bento_id,
            @product.name,
            @product.cost_price,
            menu.id,
            menu.name,
            mm.material_id,
            mm.material.name,
            mm.amount_used,
            mm.material.calculated_unit,
            (mm.amount_used * mm.material.cost_price).round(1)
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
            mm.material_id,
            mm.material.name,
            mm.amount_used,
            mm.material.calculated_unit,
            (mm.amount_used * mm.material.cost_price).round(1)
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
            mm.material_id,
            mm.material.name,
            mm.amount_used,
            mm.material.calculated_unit,
            (mm.amount_used * mm.material.cost_price).round(1)
          ]
          csv << csv_column_values
        end
      end
    end
  end
