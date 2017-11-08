json.material do |json|
  json.order_unit    @material.order_unit
  json.calculated_unit    @material.calculated_unit
  json.vendor_company_name    @material.vendor.company_name
  json.calculated_value    @material.calculated_value.to_s(:delimited)
end
