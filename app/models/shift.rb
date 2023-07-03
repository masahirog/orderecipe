require 'csv'
class Shift < ApplicationRecord
  belongs_to :shift_pattern
  belongs_to :fix_shift_pattern
  belongs_to :store
  belongs_to :staff


  def self.upload_data(file)
    update_shifts = []
    shift_ids = []
    CSV.foreach file.path, {encoding: 'BOM|UTF-8', headers: true} do |row|
    	row = row.to_hash
	  	id = row["id"]
	  	shift_ids << id
	  end
		shifts = Shift.where(id:shift_ids).map{|shift|[shift.id,shift]}.to_h
    CSV.foreach file.path, {encoding: 'BOM|UTF-8', headers: true} do |row|
      row = row.to_hash
	    id = row["id"].to_i
	    date = row["date"]
	    store_id = row["store_id"]
	    staff_id = row["staff_id"]
	    shift_pattern_id = row["shift_pattern_id"]
	    fix_shift_pattern_id = row["fix_shift_pattern_id"]
	    memo = row["memo"]
	    created_at = row["created_at"]
	    updated_at = row["updated_at"]
	    fixed_flag = row["fixed_flag"]
      if shifts[id].present?
        shift = shifts[id]
        shift.date = date
				shift.store_id = store_id
				shift.staff_id = staff_id
				shift.shift_pattern_id = shift_pattern_id
				shift.fix_shift_pattern_id = fix_shift_pattern_id
				shift.memo = memo
				shift.created_at = created_at
				shift.updated_at = updated_at
				shift.fixed_flag = fixed_flag
        update_shifts << shift
      end
    end
    Shift.import update_shifts, on_duplicate_key_update:[:date,:store_id,:staff_id,:shift_pattern_id,:fix_shift_pattern_id,:memo,:created_at,:updated_at,:fixed_flag]
    return
  end
end

