class KurumesiAdminDatasController < ApplicationController
  before_action :set_kurumesi_admin_data, only: [:show, :edit, :update, :destroy]

  def index
    @search = KurumesiAdminData.search(params).page(params[:page]).per(30)
  end

  def analize
    today = Date.today
    if params[:from]
      from = params[:from]
    else
      from = today - 50
    end
    if params[:to]
      to = params[:from]
    else
      to = today
    end
    @date = []
    @analitical_data = {}
    all_kurumesi_admin_datas = KurumesiAdminData.where(delivery_date:from..to)
    kurumesi_admin_datas = all_kurumesi_admin_datas.where(store_name:"枡々｜こだわり惣菜の枡弁当専門店")

    @analitical_data[:total_order_count] = kurumesi_admin_datas.count
    @analitical_data[:success_order_count] = kurumesi_admin_datas.where(status:"受注受付").count
    @analitical_data[:cancel_order_count] = kurumesi_admin_datas.where(status:"キャンセル").count
    @analitical_data[:repick_order_count] = kurumesi_admin_datas.where(status:"回収").count
    gon.count_data = []
    gon.all_count_data = []
    n = 1
    (from..to).each do |date|
      gon.count_data << kurumesi_admin_datas.where(delivery_date:date).count
      gon.all_count_data << all_kurumesi_admin_datas.where(delivery_date:date).count
      @date << Time.parse(date.to_s).to_i
    end
  end


  def monthly
    @monthly = {}
    status = params[:status]
    if params[:year].present?
      this_year = params[:year].to_i
    else
      this_year = Date.today.year
    end
    monthly_kurumesi_data = KurumesiAdminData.all
    if status
      monthly_kurumesi_data = monthly_kurumesi_data.where(status:status)
    end

    [*(1..12)].each do |month|
      initial_date = Date.new(this_year,month,1)
      monthly_kurumesi_data = KurumesiAdminData.where(delivery_date:initial_date.all_month)

      monthly_total_price = monthly_kurumesi_data.sum(:total_price).to_i
      monthly_order_count = monthly_kurumesi_data.count.to_i
      @monthly.store(initial_date,[monthly_total_price,monthly_order_count])
    end
  end

  def daily
    @daily = {}
    # Date.today.all_month.each do |date|
    start = params[:date][0].to_date
    fin = start.end_of_month
    (start..fin).each do |date|
      price = KurumesiAdminData.where(delivery_date:date).sum(:total_price).to_i
      @daily.store(date,price)
    end
    # @kurumesi_admin_datas = KurumesiAdminData.
  end


  def show
  end

  def new
    @kurumesi_admin_data = KurumesiAdminData.new
  end

  def edit
  end

  def create
    @kurumesi_admin_data = KurumesiAdminData.new(kurumesi_admin_data_params)

    respond_to do |format|
      if @kurumesi_admin_data.save
        format.html { redirect_to @kurumesi_admin_data, notice: 'Kurumesi admin datum was successfully created.' }
        format.json { render :show, status: :created, location: @kurumesi_admin_data }
      else
        format.html { render :new }
        format.json { render json: @kurumesi_admin_data.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @kurumesi_admin_data.update(kurumesi_admin_data_params)
        format.html { redirect_to @kurumesi_admin_data, notice: 'Kurumesi admin datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @kurumesi_admin_data }
      else
        format.html { render :edit }
        format.json { render json: @kurumesi_admin_data.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @kurumesi_admin_data.destroy
    respond_to do |format|
      format.html { redirect_to _kurumesi_admin_data_url, notice: 'Kurumesi admin datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_kurumesi_admin_data
      @kurumesi_admin_data = KurumesiAdminData.find(params[:id])
    end

    def kurumesi_admin_data_params
      params.fetch(:kurumesi_admin_data, {})
    end
end
