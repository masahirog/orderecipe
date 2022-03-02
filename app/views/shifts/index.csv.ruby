require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(スタッフコード 日付 グル―プ名 ポジション名 出勤時刻 退勤時刻 休憩開始時間 終了時間 非公開メモ 公開メモ)
  csv << csv_column_names
  @shifts.each do |shift|
    csv_column_values = [shift[1].staff.id, shift[1].date,'','',shift[1]]
    csv << csv_column_values
  end
end
