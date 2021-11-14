class SmaregiMember < ApplicationRecord
  enum sex: {minyuryoku:0,man:1,woman:2,}
  enum main_use_store: {nyuryokunasi:0,higashi_nakano:1,test:2,shin_nakano:3}
  def self.smaregidatas_raiten_count_calculate
    update_smaregi_members_arr = []
    sth_arr = []
    kaiin_kaisu = {}
    smaregi_trading_histories = SmaregiTradingHistory.where.not(kaiin_id:nil).where(torihiki_meisaikubun:1,uchikeshi_kubun:0,torihikimeisai_id:1)
    last_store_date = smaregi_trading_histories.order(date:'asc').map{|sth|[sth.kaiin_id,sth.date]}.to_h
    kaiin_id_count = smaregi_trading_histories.group(:kaiin_id).count
    SmaregiMember.all.each do |sm|
      sm.raiten_kaisu = kaiin_id_count[sm.kaiin_id] if kaiin_id_count[sm.kaiin_id].present?
      sm.last_visit_store = last_store_date[sm.kaiin_id] if last_store_date[sm.kaiin_id].present?
      update_smaregi_members_arr << sm
    end
    SmaregiMember.import update_smaregi_members_arr,on_duplicate_key_update:[:raiten_kaisu,:last_visit_store]
  end
end
