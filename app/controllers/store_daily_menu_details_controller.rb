class StoreDailyMenuDetailsController < AdminController
  before_action :set_store_daily_menu_detail, only: %i[ show edit update destroy ]

  # def index
  #   @store_daily_menu_details = StoreDailyMenuDetail.all
  # end

  # def create
  #   @store_daily_menu_detail = StoreDailyMenuDetail.new(store_daily_menu_detail_params)
  #
  #   respond_to do |format|
  #     if @store_daily_menu_detail.save
  #       format.html { redirect_to store_daily_menu_detail_url(@store_daily_menu_detail), notice: "Store daily menu detail was successfully created." }
  #       format.json { render :show, status: :created, location: @store_daily_menu_detail }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @store_daily_menu_detail.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def update
    respond_to do |format|
      if @store_daily_menu_detail.update(store_daily_menu_detail_params)
        format.html { redirect_to store_daily_menu_detail_url(@store_daily_menu_detail), notice: "Store daily menu detail was successfully updated." }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @store_daily_menu_detail.destroy

    respond_to do |format|
      format.html { redirect_to store_daily_menu_details_url, notice: "Store daily menu detail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_store_daily_menu_detail
      @store_daily_menu_detail = StoreDailyMenuDetail.find(params[:id])
    end

    def store_daily_menu_detail_params
      params.require(:store_daily_menu_detail).permit(:id)
    end
end
