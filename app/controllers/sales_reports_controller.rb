class SalesReportsController < ApplicationController
  before_action :set_sales_report, only: %i[ show edit update destroy ]

  def index
    if params[:date]
      date =Date.parse(params[:date])
    else
      date = Date.today
      params[:date] = date
    end
    @from = date.beginning_of_month
    @to = date.end_of_month
    @stores = Store.where(group_id:9)
    @sales_reports = SalesReport.where(date:@from..@to).map{|sr|[[sr.date,sr.store_id],sr.id]}.to_h
  end

  def show
    @analysis = @sales_report.analysis
  end

  def new
    @staffs = Staff.joins(:store).where(:stores => {group_id:9}).where(employment_status:1,status:0)
    date = params[:date]
    store_id = params[:store_id]
    @analysis = Analysis.find_by(date:date,store_id:store_id)
    if @analysis.present?
      @sales_report = SalesReport.new(date:date,store_id:store_id,analysis_id:@analysis.id)
    else
      redirect_to select_store_sales_reports_path,danger: "日付を確認するか、先にスマレジの情報をアップロードしてください。"
    end

  end

  def edit
    @staffs = Staff.joins(:store).where(:stores => {group_id:9}).where(employment_status:1,status:0)
    @analysis = @sales_report.analysis
  end

  def create
    @sales_report = SalesReport.new(sales_report_params)
    sozai_ureyuki = params[:sales_report][:sozai_ureyuki]
    bento_ureyuki = params[:sales_report][:bento_ureyuki]
    kome_amari = params[:sales_report][:kome_amari]
    respond_to do |format|
      if @sales_report.save
        NotificationMailer.sales_report_send(@sales_report,@sales_report.analysis,sozai_ureyuki,bento_ureyuki,kome_amari).deliver
        NotificationMailer.report_kindness_send(@sales_report).deliver
        format.html { redirect_to @sales_report, success: "作成！" }
        format.json { render :show, status: :created, location: @sales_report }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sales_report.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @sales_report.update(sales_report_params)
        format.html { redirect_to @sales_report, success: "更新！" }
        format.json { render :show, status: :ok, location: @sales_report }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sales_report.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sales_report.destroy
    respond_to do |format|
      format.html { redirect_to sales_reports_url, notice: "Sales report was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_sales_report
      @sales_report = SalesReport.find(params[:id])
    end

    def sales_report_params
      params.require(:sales_report).permit(:store_id,:date,:staff_id,:sales_amount,:sales_count,:good,:issue,:other_memo,:analysis_id,:cash_error)
    end
end
