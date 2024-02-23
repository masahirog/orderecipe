class AddIndexToSmaregiTradingHistories < ActiveRecord::Migration[6.0]
  def change
    add_index :smaregi_trading_histories, :date
    add_index :smaregi_trading_histories, :analysis_id
    add_index :smaregi_trading_histories, :kaiin_id
  end
end
