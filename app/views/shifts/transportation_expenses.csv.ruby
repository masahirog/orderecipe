require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(スタッフID スタッフ名 日付 出勤店舗 出勤シフト メモ)
  csv << csv_column_names
  @shifts.each do |shift|
    if shift.store_id.present?
      store_name = shift.store.name
    else
      store_name = ""
    end
    if shift.fix_shift_pattern_id.present?
      pattern_name = shift.fix_shift_pattern.pattern_name
    else
      pattern_name = ''
    end
    csv_column_values = [shift.staff_id,shift.staff.name,shift.date,store_name,pattern_name,shift.memo]
    csv << csv_column_values
  end
end
