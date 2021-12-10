class Analysis < ApplicationRecord
  has_many :smaregi_trading_histories
  has_many :analysis_products
  has_many :sales_reports
  belongs_to :store
  validates :store_id, :uniqueness => {:scope => :date}

  def self.recollection_datas
    meisaikubun_plus_all = SmaregiTradingHistory.where(torihiki_meisaikubun:1)
    analysis_fourteen_transaction_count = meisaikubun_plus_all.where('time < ?','14:00').select(:torihiki_id).distinct.group(:analysis_id).count

    meisaikubun_plus = meisaikubun_plus_all.where(bumon_id:1)
    meisaikubun_mainasu = SmaregiTradingHistory.where(bumon_id:1,torihiki_meisaikubun:2)

    plus = meisaikubun_plus.group(:analysis_id).sum(:suryo)
    mainasu = meisaikubun_mainasu.group(:analysis_id).sum(:suryo)
    mainasu = mainasu.map{|key,val|[key,-1*val]}.to_h
    analysis_total_number_sales_sozai = plus.merge(mainasu){|k, v1, v2| v1 + v2}

    fourteen_plus = meisaikubun_plus.where('time < ?','14:00').group(:analysis_id).sum(:suryo)
    fourteen_mainasu = meisaikubun_mainasu.where('time < ?','14:00').group(:analysis_id).sum(:suryo)
    fourteen_mainasu = fourteen_mainasu.map{|key,val|[key,-1*val]}.to_h
    analysis_fourteen_number_sales_sozai = fourteen_plus.merge(fourteen_mainasu){|k, v1, v2| v1 + v2}

    update_analysis_arr = []
    Analysis.all.each do |analysis|
      analysis.total_number_sales_sozai = analysis_total_number_sales_sozai[analysis.id]
      analysis.fourteen_number_sales_sozai = analysis_fourteen_number_sales_sozai[analysis.id]
      analysis.fourteen_transaction_count = analysis_fourteen_transaction_count[analysis.id]
      update_analysis_arr << analysis
    end
    Analysis.import update_analysis_arr, on_duplicate_key_update:[:total_number_sales_sozai,:fourteen_number_sales_sozai,:fourteen_transaction_count]
  end

  def self.recollection_early_sales_number
    update_ap_arr = []
    meisaikubun_plus = SmaregiTradingHistory.where(torihiki_meisaikubun:1).where('time < ?','14:00')
    meisaikubun_mainasu = SmaregiTradingHistory.where(torihiki_meisaikubun:2).where('time < ?','14:00')
    ap_plus = meisaikubun_plus.group(:analysis_id,:hinban).sum(:suryo)
    ap_mainasu = meisaikubun_mainasu.group(:analysis_id,:hinban).sum(:suryo)
    ap_mainasu = ap_mainasu.map{|key,val|[key,-1*val]}.to_h
    analysis_product_sales_number = ap_plus.merge(ap_mainasu){|k, v1, v2| v1 + v2}
    AnalysisProduct.where.not(product_id: nil).each do |ap|
      if analysis_product_sales_number[[ap.analysis_id,ap.product_id]].present?
        ap.early_sales_number = analysis_product_sales_number[[ap.analysis_id,ap.product_id]]
        update_ap_arr << ap
      end
    end
    AnalysisProduct.import update_ap_arr, on_duplicate_key_update:[:early_sales_number]
  end

  def self.recalculate_analysis_product_potential
    analysis_product_arr = []
    Analysis.all.each do |analysis|
      potential_keisu = (analysis.total_number_sales_sozai/analysis.fourteen_number_sales_sozai.to_f)
      analysis.analysis_products.each do |ap|
        ap.potential = (potential_keisu * ap.early_sales_number).round(1)
        analysis_product_arr << ap
      end
    end
    AnalysisProduct.import analysis_product_arr, on_duplicate_key_update:[:potential]
  end

end
