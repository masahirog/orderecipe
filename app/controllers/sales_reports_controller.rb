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
      moritsuke_gosa = ""
      @analysis.store_daily_menu.store_daily_menu_details.each do |sdmd|
        unless sdmd.excess_or_deficiency_number == 0
          moritsuke_gosa += "#{sdmd.product.name}：#{sdmd.excess_or_deficiency_number}食\n"
        end
      end
      @sales_report = SalesReport.new(date:date,store_id:store_id,analysis_id:@analysis.id,excess_or_deficiency_number_memo:moritsuke_gosa)
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
        analysis = @sales_report.analysis
        sales_form="店舗名:#{analysis.store.name}\n"+
        "日付:#{analysis.store_daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[analysis.store_daily_menu.start_time.wday]})")}\n"+
        "担当者:#{Staff.find(@sales_report.staff_id).name}\n"+
        "純売上(税抜):#{analysis.ex_tax_sales_amount.to_s(:delimited)}円\n"+
        "来店者数:#{analysis.transaction_count}組\n"+
        "値引き金額:#{analysis.discount_amount.to_s(:delimited)}円\n"+
        "廃棄金額:#{analysis.loss_amount.to_s(:delimited)}円\n"+
        "廃棄率:#{((analysis.loss_amount.to_f/analysis.ex_tax_sales_amount)*100).round(1)}%\n"+
        "ロス金額:#{(analysis.loss_amount.to_f + analysis.discount_amount.to_f).round}円\n"+
        "ロス率:#{(((analysis.loss_amount.to_f + analysis.discount_amount.to_f)/analysis.ex_tax_sales_amount)*100).round(1)}%\n"+
        "現金誤差:#{@sales_report.cash_error}円\n"+
        "惣菜の売れ行き：#{sozai_ureyuki}\n"+
        "弁当の売れ行き：#{bento_ureyuki}\n"+
        "白米のあまり：#{kome_amari} kg\n"+
        "親切にできた点（自分・周りのスタッフ）:\n#{@sales_report.good}\n"+
        "課題に感じた点：\n#{@sales_report.issue}\n"+
        "惣菜の盛り付け過不足の有無：\n#{@sales_report.excess_or_deficiency_number_memo}\n"+
        "その他メモ:#{@sales_report.other_memo}"
        Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:').ping(sales_form)

        kindess_message = "#{Staff.find(@sales_report.staff_id).name} さんから\n"+
        "ーーーーー\n"+
        "#{@sales_report.good}"
        Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':hugging_face:').ping(kindess_message)

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
      params.require(:sales_report).permit(:store_id,:date,:staff_id,:sales_amount,:sales_count,:good,:issue,:other_memo,:analysis_id,:cash_error,:excess_or_deficiency_number_memo)
    end
end
