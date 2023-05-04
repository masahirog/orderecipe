class SalesReport < ApplicationRecord
  belongs_to :analysis
  belongs_to :staff
end
