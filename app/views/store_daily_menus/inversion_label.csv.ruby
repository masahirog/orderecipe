require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(id shohinmei date)
  csv << csv_column_names
  date = @store_daily_menu.start_time  
  @store_daily_menu_details.each do |sdmd|
    if sdmd.product.container_id.present?
      if sdmd.product.container.inversion_label_flag == true
        sdmd.sozai_number.times{
          csv << [sdmd.product_id,sdmd.product.name,date]
        }
      end
    end
  end
end