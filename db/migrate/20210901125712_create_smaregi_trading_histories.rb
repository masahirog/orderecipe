class CreateSmaregiTradingHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :smaregi_trading_histories do |t|
      t.date :date
      t.integer :analysis_id
      t.integer :torihiki_id
      t.datetime :torihiki_nichiji
      t.integer :tanka_nebikimae_shokei
      t.integer :tanka_nebiki_shokei
      t.integer :shokei
      t.integer :shikei_nebiki
      t.float :shokei_waribikiritsu
      t.integer :point_nebiki
      t.integer :gokei
      t.integer :suryo_gokei
      t.integer :henpinsuryo_gokei
      t.integer :huyo_point
      t.integer :shiyo_point
      t.integer :genzai_point
      t.integer :gokei_point
      t.integer :tenpo_id
      t.integer :kaiin_id
      t.string :kaiin_code
      t.integer :tanmatsu_torihiki_id
      t.integer :nenreiso
      t.integer :kyakuso_id
      t.integer :hanbaiin_id
      t.string :hanbaiin_mei
      t.integer :torihikimeisai_id
      t.integer :torihiki_meisaikubun
      t.integer :shohin_id
      t.bigint :shohin_code
      t.integer :hinban
      t.string :shohinmei
      t.integer :shohintanka
      t.integer :hanbai_tanka
      t.integer :tanpin_nebiki
      t.integer :tanpin_waribiki
      t.integer :suryo
      t.integer :nebikimaekei
      t.integer :tanka_nebikikei
      t.integer :nebikigokei
      t.integer :bumon_id
      t.string :bumonmei
      t.timestamps
      t.time :time
      t.integer :uchikeshi_torihiki_id
      t.integer :uchikeshi_kubun
      t.bigint :receipt_number
    end
  end
end
