class ManualDirectory < ApplicationRecord
	has_ancestry
	has_many :manuals, dependent: :destroy
	accepts_nested_attributes_for :manuals, allow_destroy: true
end
