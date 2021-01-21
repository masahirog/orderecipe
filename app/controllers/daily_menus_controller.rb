class DailyMenusController < ApplicationController
  before_action :set_daily_menu, only: [:show, :edit, :update, :destroy]
  def index
    @daily_menus = DailyMenu.includes(daily_menu_details:[:product]).all
  end

  def show
    @date = @daily_menu.start_time
    @daily_menu_details = @daily_menu.daily_menu_details.includes(:product)
    @hash = @daily_menu_details.map do |dmd|
      [dmd.place_showcase_id,dmd.product.name] if dmd.place_showcase_id.present?
    end
    @hash = @hash.compact.to_h
  end

  def new
    @products = Product.where(brand_id:111)
    date = params['start_time']
    @date = Date.parse(date)
    @place_showcases = PlaceShowcase.all
    if DailyMenu.where(start_time:date).present?
      id = DailyMenu.find_by(start_time:date).id
      redirect_to "/daily_menus/#{id}/edit"
    else
      @daily_menu = DailyMenu.new
      @daily_menu_details = []
      @hash = {}
    end
  end

  def edit
    saveble_photo_nums = 2 - @daily_menu.daily_menu_photos.length
    saveble_photo_nums.times {
      @daily_menu.daily_menu_photos.build
    }
    @date = @daily_menu.start_time
    @products = Product.where(brand_id:111)
    @place_showcases = PlaceShowcase.all
    @daily_menu_details = @daily_menu.products
    @hash = @daily_menu.daily_menu_details.map do |dmd|
      [dmd.place_showcase_id,dmd.product_id] if dmd.place_showcase_id.present?
    end
    @hash = @hash.compact.to_h
  end

  def create
    @products = Product.where(brand_id:111)
    @daily_menu = DailyMenu.new(daily_menu_params)
    respond_to do |format|
      if @daily_menu.save
        format.html { redirect_to daily_menus_path, notice: "#{params['daily_menu']['start_time']}の献立を作成しました。" }
        format.json { render :show, status: :created, location: @daily_menu }
      else
        format.html { render :new }
        format.json { render json: @daily_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @products = Product.where(brand_id:111)
    respond_to do |format|
      if @daily_menu.update(daily_menu_params)
        format.html { redirect_to @daily_menu, notice: 'Daily menu was successfully updated.' }
        format.json { render :show, status: :ok, location: @daily_menu }
      else
        format.html { render :edit }
        format.json { render json: @daily_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @daily_menu.destroy
    respond_to do |format|
      format.html { redirect_to daily_menus_url, notice: 'Daily menu was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def products_pdfs
    daily_menu = DailyMenu.includes(daily_menu_details:[product:[menus:[:materials]]]).find(params[:daily_menu_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ProductPdfAll.new(daily_menu.id,'daily_menus')
        send_data pdf.render,
        filename:    "#{daily_menu.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def sources_pdfs
    daily_menu = DailyMenu.includes(daily_menu_details:[product:[menus:[:materials]]]).find(params[:daily_menu_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = SourcesPdf.new(daily_menu.start_time,'daily_menus')
        send_data pdf.render,
        filename:    "#{daily_menu.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  # def recipes_roma
  #   daily_menu = DailyMenu.includes(daily_menu_details:[product:[menus:[:materials]]]).find(params[:daily_menu_id])
  #   respond_to do |format|
  #     format.html
  #     format.pdf do
  #       pdf = ProductPdfAllRoma.new(daily_menu.id,'daily_menus')
  #       send_data pdf.render,
  #       filename:    "#{daily_menu.id}.pdf",
  #       type:        "application/pdf",
  #       disposition: "inline"
  #     end
  #   end
  # end
  # def print_preparation
  #   mochiba = params[:mochiba]
  #   daily_menu = DailyMenu.includes(daily_menu_details:[product:[menus:[:materials]]]).find(params[:daily_menu_id])
  #   respond_to do |format|
  #     format.html
  #     format.pdf do
  #       pdf = ShogunPreparationAll.new(daily_menu,mochiba)
  #       send_data pdf.render,
  #       filename:    "#{daily_menu.id}.pdf",
  #       type:        "application/pdf",
  #       disposition: "inline"
  #     end
  #   end
  # end
  def material_preparation
    mochiba = params[:mochiba]
    lang = params[:lang]
    daily_menu = DailyMenu.find(params[:daily_menu_id])
    date = daily_menu.start_time
    sort = params[:sort].to_i
    @bentos_num_h = daily_menu.daily_menu_details.group(:product_id).sum(:manufacturing_number)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MaterialPreparation.new(@bentos_num_h,date,mochiba,lang,sort)

        send_data pdf.render,
        filename:    "#{date}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  def copy
    date = params[:date]
  end
  private
    def set_daily_menu
      @daily_menu = DailyMenu.find(params[:id])
    end

    def daily_menu_params
      params.require(:daily_menu).permit(:start_time,:total_manufacturing_number,:fixed_flag,:weather,:max_temperature,:min_temperature,daily_menu_photos_attributes: [:id,:daily_menu_id,:image],
        daily_menu_details_attributes: [:id,:daily_menu_id,:product_id,:manufacturing_number,:row_order,:_destroy,
          :serving_plate_id,:place_showcase_id,:signboard_flag,:window_pop_flag,:sold_outed])
    end
end
