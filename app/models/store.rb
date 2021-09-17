class Store < ApplicationRecord
  belongs_to :user
  has_many :store_daily_menus
  has_many :analyses
  has_many :task_template_stores
end
