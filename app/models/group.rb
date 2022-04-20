class Group < ApplicationRecord
  has_many :stores
  has_many :shift_frames
  has_many :fix_shift_patterns
end
