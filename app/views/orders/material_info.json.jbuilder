json.material do |json|
  json.order_unit    @material.order_unit
  json.calculated_unit    @material.calculated_unit
  json.vendor_company_name    @material.vendor.company_name
  json.calculated_value    @material.calculated_value
  json.order_unit_quantity    @material.order_unit_quantity
end
