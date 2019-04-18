class DailyMenusController < ApplicationController
  before_action :set_daily_menu, only: [:show, :edit, :update, :destroy]

  def index
    @daily_menus = DailyMenu.includes(daily_menu_details:[:product]).all
  end

  def show
    @daily_menu_details = @daily_menu.daily_menu_details.includes(:product)
  end

  def new
    @products = Product.all
    date = params['start_time']
    if DailyMenu.where(start_time:date).present?
      id = DailyMenu.find_by(start_time:date).id
      redirect_to "/daily_menus/#{id}/edit"
    else
      @daily_menu = DailyMenu.new
    end
  end

  def edit
    @products = Product.all
  end

  def create
    @products = Product.all
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
    @products = Product.all
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
    daily_menu = DailyMenu.find(params[:daily_menu_id])
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
  def recipes_roma
    daily_menu = DailyMenu.find(params[:daily_menu_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ProductPdfAllRoma.new(daily_menu.id,'daily_menus')
        send_data pdf.render,
        filename:    "#{daily_menu.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def print_test_all
    daily_menu = DailyMenu.find(params[:daily_menu_id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ProductPdfTestAll.new(daily_menu)
        send_data pdf.render,
        filename:    "#{daily_menu.id}.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end
  def preparation_all
    @daily_menu = DailyMenu.find(params[:daily_menu_id])
    respond_to do |format|
     format.html
     format.pdf do
       pdf = PreparationPdf.new(@daily_menu)
       send_data pdf.render,
       filename:    "preparation_all.pdf",
       type:        "application/pdf",
       disposition: "inline"
     end
   end
  end

  private
    def set_daily_menu
      @daily_menu = DailyMenu.find(params[:id])
    end

    def daily_menu_params
      params.require(:daily_menu).permit(:start_time,:total_manufacturing_number,:fixed_flag,
        daily_menu_details_attributes: [:id,:daily_menu_id,:product_id,:manufacturing_number,:row_order,:_destroy])
    end
end
