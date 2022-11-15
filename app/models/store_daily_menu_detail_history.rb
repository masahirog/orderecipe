class StoreDailyMenuDetailHistory < ApplicationRecord
  belongs_to :store_daily_menu_detail
  after_save :prepared_number_calculate
  after_destroy :prepared_number_calculate
  def prepared_number_calculate
    store_daily_menu_detail = self.store_daily_menu_detail
    prepared_number = store_daily_menu_detail.store_daily_menu_detail_histories.sum(:number)
    excess_or_deficiency_number = prepared_number - store_daily_menu_detail.sozai_number
    store_daily_menu_detail.update(prepared_number:prepared_number,excess_or_deficiency_number:excess_or_deficiency_number)
  end
end
