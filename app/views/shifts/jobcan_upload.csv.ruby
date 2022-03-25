require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(スタッフコード	日付	グル―プ名	ポジション名	出勤時刻	退勤時刻	休憩開始時間	終了時間	非公開メモ 公開メモ)
  csv << csv_column_names
  @shifts.each do |shift|
    start_time = ''
    end_time = ''
    if shift.fix_shift_pattern.present?
      unless shift.fix_shift_pattern.section=='rest'
        start_time = shift.fix_shift_pattern.start_time.strftime('%-H:%M')
        end_time = shift.fix_shift_pattern.end_time.strftime('%-H:%M')
      end
    end
    csv_column_values = [shift.staff.jobcan_staff_code,shift.date.strftime("%Y/%-m/%-d"),'べじはん','',start_time,end_time,'','','','']
    csv << csv_column_values
  end
end
