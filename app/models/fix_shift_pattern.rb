class FixShiftPattern < ApplicationRecord
  belongs_to :group
  has_many :shifts
  has_many :default_shifts
  has_many :fix_shift_pattern_shift_frames, dependent: :destroy
  has_many :shift_frames, through: :fix_shift_pattern_shift_frames
  accepts_nested_attributes_for :fix_shift_pattern_shift_frames, allow_destroy: true

  has_many :fix_shift_pattern_stores, dependent: :destroy
  has_many :stores, through: :fix_shift_pattern_stores
  accepts_nested_attributes_for :fix_shift_pattern_stores, allow_destroy: true
end
