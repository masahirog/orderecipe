
require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(id date store_id staff_id staff_code staff_name shift_pattern_id fix_shift_pattern_id memo created_at updated_at fixed_flag start_time end_time)
  csv << csv_column_names
  @shifts.each do |shift|
    shift = shift[1]
    csv_column_values = [shift.id,shift.date,shift.store_id,shift.staff_id,shift.staff.staff_code,shift.staff.name,shift.shift_pattern_id,shift.fix_shift_pattern_id,shift.memo,shift.created_at,shift.updated_at,shift.fixed_flag,shift.start_time,shift.end_time]
    csv << csv_column_values
  end
end
