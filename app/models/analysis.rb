class Analysis < ApplicationRecord
  has_many :smaregi_trading_histories
  has_many :analysis_products
  belongs_to :store
end
