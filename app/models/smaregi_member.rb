class SmaregiMember < ApplicationRecord
  enum sex: {minyuryoku:0,man:1,woman:2}
  enum main_use_store: {nyuryokunasi:0,higashi_nakano:1,shinkoenji:2,shin_nakano:3,numabukuro:4,ogikubo:5}
  def self.update_sales_data
    smaregi_members = SmaregiMember.all.map{|sm|[sm.kaiin_id,sm]}.to_h
    smaregi_trading_histories = SmaregiTradingHistory.where.not(kaiin_id:nil).select(:torihiki_id,:torihiki_meisaikubun,:kaiin_id,:date,:gokei_point).order("date ASC").distinct(:torihiki_id)
    kaisu = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    smaregi_trading_histories.each do |sth|
      if sth[:torihiki_meisaikubun]==1
        kaisu[sth[:kaiin_id]][:last_date] = sth[:date]
        if kaisu[sth[:kaiin_id]][:raiten_kaisu].present?
          kaisu[sth[:kaiin_id]][:raiten_kaisu] += 1
        else
          kaisu[sth[:kaiin_id]][:raiten_kaisu] = 1
        end
      elsif sth[:torihiki_meisaikubun]==2
        if kaisu[sth[:kaiin_id]][:raiten_kaisu].present?
          kaisu[sth[:kaiin_id]][:raiten_kaisu] -= 1
        else
          kaisu[sth[:kaiin_id]][:raiten_kaisu] = -1
        end
      end
    end
    update_arr = []
    smaregi_members.each do |id,sm|
      smaregi_member = sm
      if kaisu[id].present?
        smaregi_member.raiten_kaisu = kaisu[id][:raiten_kaisu]
        smaregi_member.last_visit_store = kaisu[id][:last_date]
      else
        smaregi_member.raiten_kaisu = 0
        smaregi_member.last_visit_store = nil
      end
      update_arr << smaregi_member
    end
    SmaregiMember.import update_arr, on_duplicate_key_update:[:raiten_kaisu,:last_visit_store]
  end

  def self.upload_data(file)
    new_members = []
    update_members = []
    saved_smaregi_members = SmaregiMember.all.map{|sm|[sm.kaiin_id,sm]}.to_h
    # member_raiten_kaisu = SmaregiTradingHistory.where.not(kaiin_id:nil).where(torihikimeisai_id:1,uchikeshi_kubun:0).group(:kaiin_id).count
    CSV.foreach file.path, {encoding: 'BOM|UTF-8', headers: true} do |row|
      row = row.to_hash
      kaiin_id = row["会員ID"].to_i
      kaiin_code = row["会員コード"]
      sei_kana = row["フリガナ(姓)"]
      mei_kana = row["フリガナ(名)"]
      mobile = row["携帯電話番号"]
      sex = row["性別(0:不明,  1:男,  2:女)"].to_i
      birthday = row["生年月日"]
      point = row["ポイント"]
      point_limit = row["ポイント期限"]
      last_visit_store = row["最終来店日時"]
      nyukaibi = row["入会日"]
      taikaibi = row["退会日"]
      memo = row["備考"]
      kaiin_zyotai = row["会員状態区分 (0:利用可, 1:利用停止, 2:紛失, 3:退会, 4:名寄せ)"]
      main_use_store = row["所属店舗"].to_i
      raiten_kaisu = 0
      # raiten_kaisu = member_raiten_kaisu[kaiin_id] if member_raiten_kaisu[kaiin_id]
      if saved_smaregi_members[kaiin_id].present?
        # smaregi_member = saved_smaregi_members[kaiin_id]
        # smaregi_member.sei_kana = sei_kana
        # smaregi_member.mei_kana = mei_kana
        # smaregi_member.mobile = mobile
        # smaregi_member.sex = sex
        # smaregi_member.birthday = birthday
        # smaregi_member.point = point
        # smaregi_member.point_limit = point_limit
        # smaregi_member.last_visit_store = last_visit_store
        # smaregi_member.taikaibi = taikaibi
        # smaregi_member.memo = memo
        # smaregi_member.kaiin_zyotai = kaiin_zyotai
        # smaregi_member.main_use_store = main_use_store
        # smaregi_member.raiten_kaisu = raiten_kaisu
        # update_members << smaregi_member
      else
        new_smaregi_member = SmaregiMember.new(kaiin_id:kaiin_id,kaiin_code:kaiin_code,sei_kana:sei_kana,mei_kana:mei_kana,mobile:mobile,sex:sex,birthday:birthday,point:point,
          point_limit:point_limit,last_visit_store:last_visit_store,nyukaibi:nyukaibi,taikaibi:taikaibi,memo:memo,kaiin_zyotai:kaiin_zyotai,main_use_store:main_use_store,raiten_kaisu:raiten_kaisu)
        new_members << new_smaregi_member
      end
    end
    # SmaregiMember.import update_members, on_duplicate_key_update:[:sei_kana,:mei_kana,:mobile,:sex,:birthday,:point,:point_limit,:last_visit_store,:taikaibi,:memo,:kaiin_zyotai,:main_use_store,:raiten_kaisu]
    SmaregiMember.import new_members
    return
  end
end
