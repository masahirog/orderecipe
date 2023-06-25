json.material do |json|
  json.order_unit    @material.order_unit
  json.vendor_company_name    @material.vendor.name
end
