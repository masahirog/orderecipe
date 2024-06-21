json.menu do |json|
  json.cost_price  @menu.cost_price
  json.calorie  @menu.menu_materials.sum(:calorie)
  json.menu_materials_info  @menu_materials_info
  json.calorie @menu.calorie
  json.protein @menu.protein
  json.lipid @menu.lipid
  json.carbohydrate @menu.carbohydrate
  json.dietary_fiber @menu.dietary_fiber
  json.salt @menu.salt
end
