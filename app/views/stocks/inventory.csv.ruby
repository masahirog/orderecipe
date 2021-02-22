require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(食材 業者 直近の在庫 在庫金額 計上単価 直近棚卸 計上単位 在庫)
  csv << csv_column_names
    @materials.each do |material|
      csv_column_values = [material.order_name,material.vendor.company_name,"#{@stocks_h[material.id][0].floor(1)} #{material.accounting_unit}｜#{@stocks_h[material.id][2]}",
        "#{@stocks_h[material.id][1].round.to_s(:delimited)}円","1#{material.accounting_unit}：#{(material.accounting_unit_quantity*material.cost_price)}円",@stocks_h[material.id][3],material.accounting_unit]
      csv << csv_column_values
    end
  end
