class FixShiftPattern < ApplicationRecord
  belongs_to :group
  has_many :shifts
  has_many :fix_shift_pattern_shift_frames, dependent: :destroy
  has_many :shift_frames, through: :fix_shift_pattern_shift_frames
  accepts_nested_attributes_for :fix_shift_pattern_shift_frames, allow_destroy: true

  enum section: {lunch:0,dinner:1,all_day:2,rest:3}
end
