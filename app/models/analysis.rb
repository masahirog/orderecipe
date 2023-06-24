class Analysis < ApplicationRecord
  has_many :smaregi_trading_histories
  has_many :analysis_products
  has_many :analysis_categories
  has_many :sales_reports
  belongs_to :store
  validates :store_id, :uniqueness => {:scope => :date}
  belongs_to :store_daily_menu


  def self.calculate_nomination_rate(from,to)
    update_analysis_product_arr = []
    analyses = Analysis.includes(:analysis_products).where(date:from..to)
    analyses.each do |analysis|
      sixteen_transaction_count = analysis.sixteen_transaction_count
      analysis.analysis_products.each do |ap|
        if sixteen_transaction_count > 0
          ap.nomination_rate = ((ap.sixteen_total_sales_number.to_f/sixteen_transaction_count)*100).round(1)
          update_analysis_product_arr << ap
        end
      end
    end
    AnalysisProduct.import update_analysis_product_arr, on_duplicate_key_update:[:nomination_rate]
  end
end
