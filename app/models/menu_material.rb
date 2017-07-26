class MenuMaterial < ActiveRecord::Base
  belongs_to :menu
  belongs_to :material
end
