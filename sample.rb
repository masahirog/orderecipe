require "pry-rails"
atr = [{"material_id"=>218, "amount_used"=>25.0},
 {"material_id"=>314, "amount_used"=>6.0},
 {"material_id"=>350, "amount_used"=>107.0},
 {"material_id"=>899, "amount_used"=>0.3},
 {"material_id"=>398, "amount_used"=>2.0},
 {"material_id"=>65, "amount_used"=>6.0},
 {"material_id"=>459, "amount_used"=>10.0},
 {"material_id"=>399, "amount_used"=>2.0},
 {"material_id"=>879, "amount_used"=>2.0},
 {"material_id"=>351, "amount_used"=>97.0},
 {"material_id"=>892, "amount_used"=>3.7},
 {"material_id"=>286, "amount_used"=>2.0},
 {"material_id"=>1, "amount_used"=>4.0},
 {"material_id"=>879, "amount_used"=>42.0},
 {"material_id"=>7, "amount_used"=>2.0},
 {"material_id"=>314, "amount_used"=>18.0},
 {"material_id"=>350, "amount_used"=>428.0},
 {"material_id"=>899, "amount_used"=>1.2},
 {"material_id"=>398, "amount_used"=>8.0},
 {"material_id"=>65, "amount_used"=>24.0},
 {"material_id"=>459, "amount_used"=>40.0},
 {"material_id"=>399, "amount_used"=>8.0},
 {"material_id"=>879, "amount_used"=>8.0}]

sample = []
 atr.each_with_object({}) do | h, obj |
   obj[h["material_id"]] ||= { "amount_used" =>  0}
   obj[h["material_id"]]["amount_used"] += h["amount_used"]
  sample = obj.map{|k, v| {"material_id"=> k}.merge(v)}
 end

puts sample
puts sample.class
