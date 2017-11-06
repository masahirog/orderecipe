json.material do |json|
  json.cost_price    @material.cost_price
  json.name    @material.name
  json.calculated_unit    @material.calculated_unit
  json.vendor_company_name    @material.vendor.company_name
  json.end_of_sales    @material.end_of_sales
end
