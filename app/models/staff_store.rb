class StaffStore < ApplicationRecord
	belongs_to :store
	belongs_to :staff, dependent: :destroy
end
