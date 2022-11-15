class StoreDailyMenuDetailHistoriesController < ApplicationController
  before_action :set_store_daily_menu_detail_history, only: %i[ update destroy ]

  def create
    @store_daily_menu_detail_history = StoreDailyMenuDetailHistory.new(store_daily_menu_detail_history_params)
    @store_daily_menu_detail = @store_daily_menu_detail_history.store_daily_menu_detail
    @i = @store_daily_menu_detail.store_daily_menu_detail_histories.count
    respond_to do |format|
      if @store_daily_menu_detail_history.save
        # @remaining_count = StoreDailyMenuDetail.where(store_daily_menu_id:@store_daily_menu_detail.store_daily_menu_id,initial_preparation_done:nil).count
        format.html { redirect_to store_daily_menu_detail_history_url(@store_daily_menu_detail_history), notice: "Store daily menu detail history was successfully created." }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @store_daily_menu_detail_history.update(store_daily_menu_detail_history_params)
        format.html { redirect_to store_daily_menu_detail_history_url(@store_daily_menu_detail_history), notice: "Store daily menu detail history was successfully updated." }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @store_daily_menu_detail = @store_daily_menu_detail_history.store_daily_menu_detail
    @store_daily_menu_detail_history.destroy
    @i = @store_daily_menu_detail.store_daily_menu_detail_histories.count
    respond_to do |format|
      format.html { redirect_to store_daily_menu_detail_histories_url, notice: "Store daily menu detail history was successfully destroyed." }
      format.js
    end
  end

  private
    def set_store_daily_menu_detail_history
      @store_daily_menu_detail_history = StoreDailyMenuDetailHistory.find(params[:id])
    end

    def store_daily_menu_detail_history_params
      params.require(:store_daily_menu_detail_history).permit(:id,:number,:store_daily_menu_detail_id)
    end
end
