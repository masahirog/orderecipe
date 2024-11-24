class SalesReport < ApplicationRecord
  belongs_to :analysis
  belongs_to :staff
  has_many :sales_report_staffs, dependent: :destroy
  accepts_nested_attributes_for :sales_report_staffs, allow_destroy: true
  has_many :sales_report_thanks,dependent: :destroy
  accepts_nested_attributes_for :sales_report_thanks, allow_destroy: true

end
