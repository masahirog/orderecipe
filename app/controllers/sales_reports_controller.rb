class SalesReportsController < AdminController
  before_action :set_sales_report, only: %i[ show edit update destroy ]

  def index
    @store = Store.find(params[:store_id])
    @sales_reports = SalesReport.where(store_id:params[:store_id]).order("id DESC").page(params[:page]).per(30)
  end

  def show
    @analysis = @sales_report.analysis
  end

  def new
    @staffs = Staff.where(group_id:current_user.group_id,employment_status:1,status:0)
    date = params[:date]
    @business_day_num = Date.parse(date).end_of_month.day
    store_id = params[:store_id]
    @analysis = Analysis.find_by(date:date,store_id:store_id)
    if @analysis.present?
      @store_daily_menu = @analysis.store_daily_menu
      @budget = @store_daily_menu.foods_budget.to_i + @store_daily_menu.vegetables_budget.to_i + @store_daily_menu.goods_budget.to_i
      moritsuke_gosa = ""
      date = @store_daily_menu.start_time
      dates = (date.beginning_of_month..date.end_of_month).to_a
      @store_daily_menus = StoreDailyMenu.includes(store_daily_menu_details:[:product]).where(start_time:dates,store_id:store_id)
      @foods_total_budget = 0
      @vegetables_total_budget = 0
      @goods_total_budget = 0
      @store_daily_menus.each do |sdm|
        @foods_total_budget += sdm.foods_budget.to_i
        @vegetables_total_budget += sdm.vegetables_budget.to_i
        @goods_total_budget += sdm.goods_budget.to_i
      end
      @total_budget = @foods_total_budget+@vegetables_total_budget+@goods_total_budget
      @analysis.store_daily_menu.store_daily_menu_details.each do |sdmd|
        unless sdmd.excess_or_deficiency_number == 0
          moritsuke_gosa += "#{sdmd.product.name}：#{sdmd.excess_or_deficiency_number}食\n"
        end
      end
      @analyses = Analysis.where(date:dates,store_id:store_id)
      @sales_report = SalesReport.new(date:date,store_id:store_id,analysis_id:@analysis.id,excess_or_deficiency_number_memo:moritsuke_gosa)
      @bumon_loss_amount = [[14,0]].to_h

      analysis_categories = AnalysisCategory.where(analysis_id:@analyses.ids)
      @bumon_ex_tax_sales_amount = analysis_categories.group(:smaregi_bumon_id).sum(:ex_tax_sales_amount)
      @bumon_discount_amount = analysis_categories.group(:smaregi_bumon_id).sum(:discount_amount)
    else
      redirect_to select_store_sales_reports_path,danger: "日付を確認するか、先にスマレジの情報をアップロードしてください。"
    end
  end

  def edit
    @staffs = Staff.where(group_id:current_user.group_id,employment_status:1,status:0)
    @analysis = @sales_report.analysis
    store_id = @analysis.store_id
    @store_daily_menu = @analysis.store_daily_menu
    @budget = @store_daily_menu.foods_budget.to_i + @store_daily_menu.vegetables_budget.to_i + @store_daily_menu.goods_budget.to_i
    moritsuke_gosa = ""
    date = @store_daily_menu.start_time
    dates = (date.beginning_of_month..date.end_of_month).to_a
    @business_day_num = date.end_of_month.day
    @store_daily_menus = StoreDailyMenu.includes(store_daily_menu_details:[:product]).where(start_time:dates,store_id:store_id)
    @foods_total_budget = 0
    @vegetables_total_budget = 0
    @goods_total_budget = 0
    @store_daily_menus.each do |sdm|
      @foods_total_budget += sdm.foods_budget.to_i
      @vegetables_total_budget += sdm.vegetables_budget.to_i
      @goods_total_budget += sdm.goods_budget.to_i
    end
    @total_budget = @foods_total_budget+@vegetables_total_budget+@goods_total_budget
    @analysis.store_daily_menu.store_daily_menu_details.each do |sdmd|
      unless sdmd.excess_or_deficiency_number == 0
        moritsuke_gosa += "#{sdmd.product.name}：#{sdmd.excess_or_deficiency_number}食\n"
      end
    end
    @analyses = Analysis.where(date:dates,store_id:store_id)
    @bumon_loss_amount = [[14,0]].to_h

    analysis_categories = AnalysisCategory.where(analysis_id:@analyses.ids)
    @bumon_ex_tax_sales_amount = analysis_categories.group(:smaregi_bumon_id).sum(:ex_tax_sales_amount)
    @bumon_discount_amount = analysis_categories.group(:smaregi_bumon_id).sum(:discount_amount) 
  end

  def create
    @sales_report = SalesReport.new(sales_report_params)
    vegetable_waste_amount = params[:sales_report][:vegetable_waste_amount]
    sozai_ureyuki = params[:sales_report][:sozai_ureyuki]
    bento_ureyuki = params[:sales_report][:bento_ureyuki]
    kome_amari = params[:sales_report][:kome_amari]
    respond_to do |format|
      if @sales_report.save
        yosan = (@sales_report.analysis.store_daily_menu.foods_budget+@sales_report.analysis.store_daily_menu.vegetables_budget+@sales_report.analysis.store_daily_menu.goods_budget
        ).to_i
        analysis = @sales_report.analysis
        analysis.update(vegetable_waste_amount:vegetable_waste_amount)
        sales_form=" *#{analysis.store_daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[analysis.store_daily_menu.start_time.wday]})")}*　*#{analysis.store.name}*　*#{Staff.find(@sales_report.staff_id).name}* \n"+
        " *予算* ： #{yosan.to_s(:delimited)}円\n"+
        " *売上(税抜)* ： #{analysis.ex_tax_sales_amount.to_s(:delimited)}円（#{analysis.transaction_count}組）\n"+
        " *値引き率* ： #{((analysis.discount_amount.to_f/analysis.ex_tax_sales_amount)*100).round(1)}%（#{analysis.discount_amount.to_s(:delimited)}円）\n"+
        " *廃棄率* ： #{((analysis.loss_amount.to_f/analysis.ex_tax_sales_amount)*100).round(1)}% （#{analysis.loss_amount.to_s(:delimited)}円）\n"+
        " *ロス率* ： #{(((analysis.loss_amount.to_f + analysis.discount_amount.to_f)/analysis.ex_tax_sales_amount)*100).round(1)}% （#{(analysis.loss_amount.to_f + analysis.discount_amount.to_f).round.to_s(:delimited)}円）\n"+
        " *野菜の廃棄* ： #{@sales_report.vegetable_waste_amount}円\n"+
        " *現金誤差* ： #{@sales_report.cash_error}円\n"+
        " *退勤時間* ： #{@sales_report.leaving_work.strftime("%-H:%M")}\n"+
        " *在庫感* ： 惣菜は#{sozai_ureyuki}、弁当は#{bento_ureyuki}、白米残#{kome_amari} kg\n\n"+
        " *課題に感じた点* ：\n#{@sales_report.issue}\n\n"+
        " *その他* ：\n#{@sales_report.other_memo}\n" +
        "ーーーーー\n"
        if params[:sales_report]["slack_notify"]=="1"
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'おつかれ様', icon_emoji: ':male-farmer:').ping(sales_form)
        end
        if @sales_report.excess_or_deficiency_number_memo
          kabusoku = " *惣菜の盛り付け過不足* \n"+
          "#{analysis.store_daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[analysis.store_daily_menu.start_time.wday]})")}　#{analysis.store.name}　#{Staff.find(@sales_report.staff_id).name}\n"+
          "\n#{@sales_report.excess_or_deficiency_number_memo}\n"+
          "ーーーーー\n"
          if params[:sales_report]["slack_notify"]=="1"
            Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'かぶそ君', icon_emoji: ':male-scientist:').ping(kabusoku)
          end
        end
        if @sales_report.good.present?
          kindess_message = "#{Staff.find(@sales_report.staff_id).name} さんから\n"+
          "ーーーーー\n"+
          "#{@sales_report.good}"
          if params[:sales_report]["slack_notify"]=="1"
            Slack::Notifier.new("https://hooks.slack.com/services/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", username: '感謝', icon_emoji: ':hugging_face:').ping(kindess_message)
          end
        end
        format.html { redirect_to sales_reports_path(store_id:@sales_report.store_id), success: "保存しました。" }
        format.json { render :show, status: :created, location: @sales_report }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sales_report.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    sozai_ureyuki = params[:sales_report][:sozai_ureyuki]
    bento_ureyuki = params[:sales_report][:bento_ureyuki]
    kome_amari = params[:sales_report][:kome_amari]
    respond_to do |format|
      if @sales_report.update(sales_report_params)
        analysis = @sales_report.analysis
        sales_form=" *#{analysis.store_daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[analysis.store_daily_menu.start_time.wday]})")}*　*#{analysis.store.name}*　*#{Staff.find(@sales_report.staff_id).name}* \n"+
        " *売上(税抜)* ： #{analysis.ex_tax_sales_amount.to_s(:delimited)}円（#{analysis.transaction_count}組）\n"+
        " *値引き率* ： #{((analysis.discount_amount.to_f/analysis.ex_tax_sales_amount)*100).round(1)}%（#{analysis.discount_amount.to_s(:delimited)}円）\n"+
        " *廃棄率* ： #{((analysis.loss_amount.to_f/analysis.ex_tax_sales_amount)*100).round(1)}% （#{analysis.loss_amount.to_s(:delimited)}円）\n"+
        " *ロス率* ： #{(((analysis.loss_amount.to_f + analysis.discount_amount.to_f)/analysis.ex_tax_sales_amount)*100).round(1)}% （#{(analysis.loss_amount.to_f + analysis.discount_amount.to_f).round.to_s(:delimited)}円）\n"+
        " *現金誤差* ： #{@sales_report.cash_error}円\n"+
        " *在庫感* ： 惣菜は#{sozai_ureyuki}、弁当は#{bento_ureyuki}、白米残#{kome_amari} kg\n\n"+
        " *課題に感じた点* ：\n#{@sales_report.issue}\n\n"+
        " *その他* ：\n#{@sales_report.other_memo}\n" +
        "ーーーーー\n"
        if params[:sales_report]["slack_notify"]=="1"
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'おつかれ様', icon_emoji: ':male-farmer:').ping(sales_form)
        end
        if @sales_report.excess_or_deficiency_number_memo
          kabusoku = " *惣菜の盛り付け過不足* \n"+
          "#{analysis.store_daily_menu.start_time.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[analysis.store_daily_menu.start_time.wday]})")}　#{analysis.store.name}　#{Staff.find(@sales_report.staff_id).name}\n"+
          "\n#{@sales_report.excess_or_deficiency_number_memo}\n"+
          "ーーーーー\n"
          if params[:sales_report]["slack_notify"]=="1"
            Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'かぶそ君', icon_emoji: ':male-scientist:').ping(kabusoku)
          end
        end
        if @sales_report.good.present?
          # kindess_message = "#{Staff.find(@sales_report.staff_id).name} さんから\n"+
          "ーーーーー\n"+
          "#{@sales_report.good}"
          if params[:sales_report]["slack_notify"]=="1"
            Slack::Notifier.new("https://hooks.slack.com/services/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", username: '感謝', icon_emoji: ':hugging_face:').ping(kindess_message)
          end
        end
        format.html { redirect_to sales_report_path(store_id:@sales_report.store_id), success: "更新しました。" }
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
      params.require(:sales_report).permit(:store_id,:date,:staff_id,:sales_amount,:sales_count,:good,:issue,:other_memo,
        :analysis_id,:cash_error,:excess_or_deficiency_number_memo,:leaving_work,:vegetable_waste_amount)
    end
end
