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
    CSV.foreach file.path, {encoding: 'Shift_JIS:UTF-8', headers: true} do |row|
    end
    WorkingHour.import new_datas
    WorkingHour.import update_datas, on_duplicate_key_update:[:working_time]
    return
  end
end
