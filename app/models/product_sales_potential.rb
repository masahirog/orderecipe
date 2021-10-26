class ProductSalesPotential < ApplicationRecord
  belongs_to :store
  belongs_to :product
  def self.recalculate_potential(store_id,product_id)
    # 計算に直近2週間分の販売データを使用する
    analysis_products = AnalysisProduct.joins(:analysis).order("analyses.date desc").where(:analyses => {store_id:store_id}).where(product_id:product_id,exclusion_flag:false).limit(12)
    if analysis_products.map{|ap|ap.potential}.reject(&:blank?).sum > 0 && analysis_products.count > 0
      potential_average = (analysis_products.map{|ap|ap.potential}.reject(&:blank?).sum/analysis_products.count).round
    else
      potential_average = 0
    end
    return potential_average
  end
end
