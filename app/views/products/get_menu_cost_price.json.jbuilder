json.menu do |json|
  json.cost_price  @menu.cost_price
  json.calorie  @menu.menu_materials.sum(:calorie)
  json.menu_materials_info  @menu_materials_info
end
