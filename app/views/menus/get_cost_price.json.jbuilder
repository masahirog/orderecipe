json.material do |json|
  json.id @material.id
  json.cost_price @material.cost_price
  json.name @material.name
  json.recipe_unit @material.recipe_unit
  json.vendor_company_name @material.vendor.name
  json.unused_flag @material.unused_flag
  json.material_cut_patterns @material.material_cut_patterns
  json.food_ingredient @food_ingredient
  json.recipe_unit_gram_quantity @material.recipe_unit_gram_quantity
end
