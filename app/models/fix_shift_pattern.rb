class FixShiftPattern < ApplicationRecord
  has_many :shifts
  enum section: {lunch:0,dinner:1,all_day:2}

  SELECT_OPTIONS = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
  # SELECT_OPTIONS = []
  FixShiftPattern.all.each do |fsp|
    if SELECT_OPTIONS[fsp.section].present?
      SELECT_OPTIONS[fsp.section] << [fsp.pattern_name,fsp.id]
    else
      SELECT_OPTIONS[fsp.section] = [[fsp.pattern_name,fsp.id]]
    end
  end
end
