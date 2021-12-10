class SalesReport < ApplicationRecord
  enum staff_id: {kamiharako:1, t_sato:2,komaki:3,terada:4,furukawa:5,ooshimizu:6}
  belongs_to :analysis

end
