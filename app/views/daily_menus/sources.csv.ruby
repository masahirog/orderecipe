require 'csv'
CSV.generate do |csv|
  csv_column_names = %w()
  csv << csv_column_names
  @daily_menu.daily_menu_details.each do |dmd|
    num = dmd.manufacturing_number
    dmd.product.product_menus.each do |pm|
      pm.menu.menu_materials.each do |mm|

      end
    end
    csv_column_values = []
    csv << csv_column_values
  end
end
