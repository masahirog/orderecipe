class SalesReportStaff < ApplicationRecord
	belongs_to :sales_report
	belongs_to :staff
end
