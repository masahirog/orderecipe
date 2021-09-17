class Task < ApplicationRecord
  belongs_to :store
  enum status: {未完了:0,完了:1}
end
