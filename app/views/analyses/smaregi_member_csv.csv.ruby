require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(会員ID 会員コード 名前  性別 生年月日 ポイント 最終来店日時 入会日 退会日 備考 所属店舗 来店回数)
  csv << csv_column_names
  @smaregi_members.each do |sm|
    csv << [sm.kaiin_id,sm.kaiin_code,"#{sm.sei_kana} #{sm.mei_kana}",sm.sex,sm.birthday,sm.point,sm.last_visit_store,sm.nyukaibi,sm.taikaibi,sm.memo,sm.main_use_store,sm.raiten_kaisu]
  end
end
