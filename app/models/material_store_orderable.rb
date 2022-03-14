class MaterialStoreOrderable < ApplicationRecord
  belongs_to :store
  belongs_to :material
end
