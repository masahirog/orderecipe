class SalesReport < ApplicationRecord
  enum staff_id: {kamiharako:1, t_sato:2,komaki:3,terada:4,furukawa:5,ooshimizu:6,nishino:7,katayama:8,yamashita:9}
  belongs_to :analysis

end
