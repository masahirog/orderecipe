require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(名前 従業員番号 日付	勤怠区分 開始時刻 終了時刻)
  csv << csv_column_names
  @shifts.each do |shift|
    if shift.fix_shift_pattern_id.present?
      if shift.fix_shift_pattern.working_hour == 0
        division = "休日"
      else
        division = "平日"
      end
    else
      division = "休日"
    end
    if shift.start_time.present?
      start_time = shift.start_time.strftime("%-H:%M")
    else
      start_time = ""
    end
    if shift.end_time.present?
      end_time = shift.end_time.strftime("%-H:%M")
    else
      end_time = ""
    end
    

    csv_column_values = [shift.staff.name,shift.staff.staff_code,shift.date.strftime("%Y/%m/%d"),division,start_time,end_time]
    csv << csv_column_values
  end
end
