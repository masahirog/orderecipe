require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(ID 食材名 ひらがな 単位 単価 　 日付記入 在庫記入 単位 直近の在庫変動 直近の在庫量 単位 金額 仕入先 棚卸分類 直近の棚卸し日 店舗)
  csv << csv_column_names
    @materials.each do |material|
      csv_column_values = [material.id,material.name,material.short_name,"1 #{material.accounting_unit}",material.accounting_unit_quantity*material.cost_price,"円",'','',material.accounting_unit,@stocks_h[material.id][2],@stocks_h[material.id][0].floor(1),material.accounting_unit,@stocks_h[material.id][1].round(1),material.vendor.name,
        t("enums.material.storage_place.#{material.storage_place}"),@stocks_h[material.id][3],@store.short_name]
      csv << csv_column_values
    end
  end
