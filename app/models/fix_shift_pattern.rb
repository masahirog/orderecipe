class FixShiftPattern < ApplicationRecord
  has_many :shifts
  enum section: {lunch:0,dinner:1,all_day:2}


end
