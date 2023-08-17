
require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(id date store_id staff_code staff_name shift_pattern_id fix_shift_pattern_id memo start_time end_time working_hour)
  csv << csv_column_names
  @shifts.each do |shift|
    shift = shift[1]
    store = ""
    fix_shift_pattern = ""
    shift_pattern = ""
    start_time = ""
    end_time = ""
    working_hour = ""
    store = shift.store.name if shift.store_id.present?
    fix_shift_pattern = shift.fix_shift_pattern.pattern_name if shift.fix_shift_pattern_id.present?
    shift_pattern = shift.shift_pattern.pattern_name if shift.shift_pattern_id.present?
    start_time = shift.start_time.strftime("%H:%M") if shift.start_time.present?
    end_time = shift.end_time.strftime("%H:%M") if shift.end_time.present?
    working_hour = shift.fix_shift_pattern.working_hour if shift.fix_shift_pattern_id.present?
    csv_column_values = [shift.id,shift.date,store,shift.staff.staff_code,shift.staff.name,shift_pattern,fix_shift_pattern,shift.memo,start_time,end_time,working_hour]
    csv << csv_column_values
  end
end
