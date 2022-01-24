require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(ID 食材名 ひらがな 日付 在庫 単位 直近在庫 仕入先 棚卸分類)
  csv << csv_column_names
    @materials.each do |material|
      csv_column_values = [material.id,material.name,material.short_name,'','',material.accounting_unit,"#{@stocks_h[material.id][2]} #{@stocks_h[material.id][0].floor(1)}#{material.accounting_unit}",
        material.vendor.company_name,t("enums.material.storage_place.#{material.storage_place}")]
      csv << csv_column_values
    end
  end
