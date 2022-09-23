class MenuCookCheck < ApplicationRecord
  belongs_to :menu

  enum check_position:{調理場:1,作業場:2}
end
