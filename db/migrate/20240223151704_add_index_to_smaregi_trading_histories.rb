class AddIndexToSmaregiTradingHistories < ActiveRecord::Migration[6.0]
  def change
    add_index :smaregi_trading_histories, [:date,:analysis_id,:kaiin_id], name: 'sth_index'
  end
end
