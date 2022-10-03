class MenuCookCheck < ApplicationRecord
  belongs_to :menu

  enum check_position:{調理:1,積載:2}
end
