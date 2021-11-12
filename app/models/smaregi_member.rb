class SmaregiMember < ApplicationRecord
  enum sex: {minyuryoku:0,man:1,woman:2,}
  enum main_use_store: {nyuryokunasi:0,higashi_nakano:1,test:2,shin_nakano:3}
  def self.smaregidatas_raiten_count_calculate
    update_smaregi_members_arr = []
    sth_arr = []
    kaiin_kaisu = {}
    torihiki_ids = []
    SmaregiTradingHistory.where(torihiki_meisaikubun:1).each do |sth|
      unless torihiki_ids.include?(sth.torihiki_id)
        if kaiin_kaisu[sth.kaiin_id].present?
          kaiin_kaisu[sth.kaiin_id] += 1
        else
          kaiin_kaisu[sth.kaiin_id] = 1
        end
        torihiki_ids << sth.torihiki_id
      end
    end
    kaiin_kaisu.each do |kk|
      if kk[0].present?
        smaregi_member = SmaregiMember.find_by(kaiin_id:kk[0])
        if smaregi_member.present?
          smaregi_member.raiten_kaisu = kk[1]
          update_smaregi_members_arr << smaregi_member
        end
      end
    end
    SmaregiMember.import update_smaregi_members_arr,on_duplicate_key_update:[:raiten_kaisu]
  end
end
