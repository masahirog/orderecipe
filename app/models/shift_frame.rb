class ShiftFrame < ApplicationRecord
  belongs_to :group
  has_many :fix_shift_pattern_shift_frames
  has_many :fix_shift_patterns, through: :fix_shift_pattern_shift_frames

  has_many :store_shift_frames
end
