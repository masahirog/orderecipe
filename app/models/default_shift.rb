class DefaultShift < ApplicationRecord
  belongs_to :staff
  belongs_to :fix_shift_pattern
  belongs_to :store
end
