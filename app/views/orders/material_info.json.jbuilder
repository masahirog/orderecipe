json.material do |json|
  json.order_unit    @material.order_unit
  json.recipe_unit    @material.recipe_unit
  if @material.vendor_stock_flag == false
    json.vendor_company_name    @material.vendor.company_name + "【受注品】"
    json.color   'red'
  else
    json.vendor_company_name    @material.vendor.company_name
    json.color  ''
  end
  if @material.delivery_deadline > 1
    json.delivery_deadline     @material.delivery_deadline.to_s + "営業日前に必要！"
    json.color   'red'
  else
    json.delivery_deadline   ""
    json.color  ''
  end

  json.recipe_unit_quantity    @material.recipe_unit_quantity
  json.order_unit_quantity    @material.order_unit_quantity
end
