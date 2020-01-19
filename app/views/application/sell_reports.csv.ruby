require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(date total_count total_number masu_co masu_num hasi_co hasi_num don_co don_num suzu_co suzu_num)
  csv << csv_column_names
    @date_counts.each do |date_count|
      csv_column_values = [date_count[0],date_count[1],@date_numbers[date_count[0]],@date_brand_counts[[date_count[0],11]],
      @date_brand_sums[[date_count[0],11]],@date_brand_counts[[date_count[0],21]],@date_brand_sums[[date_count[0],21]],
      @date_brand_counts[[date_count[0],31]],@date_brand_sums[[date_count[0],31]],
      @date_brand_counts[[date_count[0],51]],@date_brand_sums[[date_count[0],51]]]
      csv << csv_column_values
    end
  end
