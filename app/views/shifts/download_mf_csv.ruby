require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(従業員番号 苗字  名前  日付  勤怠区分  勤務パターン  開始時刻  終了時刻  休憩開始時刻1 休憩終了時刻1 休憩開始時刻2 休憩終了時刻2 休憩開始時刻3 休憩終了時刻3)
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
    

    csv_column_values = [shift.staff.staff_code,shift.staff.name,'',shift.date.strftime("%Y/%m/%d"),division,"",start_time,end_time,"","","","","",""]
    csv << csv_column_values
  end
end
