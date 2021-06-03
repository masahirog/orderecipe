require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(ID 食材 業者 在庫 単位 日付 金額 計上単価)
  csv << csv_column_names
    @materials.each do |material|
      csv_column_values = [material.id,material.order_name,material.vendor.company_name,@stocks_h[material.id][0].floor(1),material.accounting_unit,@stocks_h[material.id][2],
        "#{@stocks_h[material.id][1].round.to_s(:delimited)}円","1#{material.accounting_unit}：#{(material.accounting_unit_quantity*material.cost_price)}円"]
      csv << csv_column_values
    end
  end
