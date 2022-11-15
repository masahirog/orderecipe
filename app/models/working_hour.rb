require 'csv'
class WorkingHour < ApplicationRecord
  attr_accessor :position
  def self.upload_data(file,group_id)
    new_datas = []
    update_datas = []
    dates = []
    if group_id == "19"
      store_id = 39
    else
      store_id = nil
    end
    # CSVファイル読み込み部分
    CSV.foreach file.path, {encoding: 'Shift_JIS:UTF-8', headers: true} do |row|
      row = row.to_hash
      dates << row["(年月日)"]
    end
    dates = dates.uniq
    working_hours_hash = WorkingHour.where(date:dates).map{|wh|[[wh.date,wh.jobcan_staff_code],wh]}.to_h
    staff_hash = Staff.where(store_id:store_id).map{|staff|[staff.jobcan_staff_code,staff.id]}.to_h
    CSV.foreach file.path, {encoding: 'Shift_JIS:UTF-8', headers: true} do |row|
      row = row.to_hash
      working_time = row["実労働時間"].to_f
      if working_time == 0
      else
        date = row["(年月日)"].to_date
        name = row["姓 名"]
        jobcan_staff_code = row["スタッフコード"].to_i
        staff_id = staff_hash[jobcan_staff_code]
        if working_hours_hash[[date,jobcan_staff_code]].present?
          working_hour = working_hours_hash[[date,jobcan_staff_code]]
          working_hour.working_time = working_time
          update_datas << working_hour
        else
          new_jobcan_data = WorkingHour.new(date:date,name:name,working_time:working_time,jobcan_staff_code:jobcan_staff_code,group_id:group_id,store_id:store_id)
          new_datas << new_jobcan_data
        end
      end
    end
    WorkingHour.import new_datas
    WorkingHour.import update_datas, on_duplicate_key_update:[:working_time]
    return
  end
end
