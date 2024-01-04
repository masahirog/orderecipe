require 'csv'
CSV.generate do |csv|
  csv_column_names = @bumon.map{|data|data[1]}
  csv_column_names.unshift "日付", "合計"
  csv << csv_column_names
  @analyses.each do |analysis|
    csv_data =[]
    date = analysis.date
    if @pattern == "0"
      sum = @hash[analysis.id].values.map{|ac|ac.ex_tax_sales_amount}.sum
    else
      sum = @hash[analysis.id].values.map{|ac|ac.sales_number}.sum
    end
    csv_data =[date,sum]
    @bumon.each do |data|
      if @pattern == "0"
        csv_data << @hash[analysis.id][data[0].to_i].ex_tax_sales_amount if @hash[analysis.id][data[0].to_i].present?
      else
        csv_data << @hash[analysis.id][data[0].to_i].sales_number if @hash[analysis.id][data[0].to_i].present?
      end
    end
    csv << csv_data
  end
end
