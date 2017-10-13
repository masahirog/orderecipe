json.product do |json|
  json.array! (@menu) do |menu|
    json.id    menu.id
    json.name    menu.name
  end
end
