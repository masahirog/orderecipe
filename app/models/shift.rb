class Shift < ApplicationRecord
  belongs_to :shift_pattern
  belongs_to :fix_shift_pattern
  belongs_to :store
end
