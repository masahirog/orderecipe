json.material do |json|
  json.order_unit    @material.order_unit
  json.calculated_unit    @material.calculated_unit
  if @material.vendorstock_flag == true
    json.vendor_company_name    @material.vendor.company_name + "：卸業者在庫品"
    json.color   ''
  elsif @material.vendorstock_flag == false
    json.vendor_company_name    @material.vendor.company_name + "：メーカー発注品"
    json.color  'red'
  else
    json.vendor_company_name    @material.vendor.company_name
    json.color  ''
  end
  json.calculated_value    @material.calculated_value
  json.order_unit_quantity    @material.order_unit_quantity
end
