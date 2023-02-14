class Analysis < ApplicationRecord
  has_many :smaregi_trading_histories
  has_many :analysis_products
  has_many :analysis_categories
  has_many :sales_reports
  belongs_to :store
  validates :store_id, :uniqueness => {:scope => :date}
  belongs_to :store_daily_menu

end
