class WeeklyReportsController < ApplicationController
  before_action :set_weekly_report, only: %i[ show edit update destroy ]

  def index
    @weekly_reports = WeeklyReport.all
  end

  def show
  end

  def new
    @weekly_report = WeeklyReport.new(date:@today)
    @weekly_report.weekly_report_thanks.build
    @stores = current_user.group.stores
    @staffs = Staff.where(group_id:current_user.group_id,status:0,employment_status:1)
    @all_staffs = Staff.where(group_id:current_user.group_id,status:0)
  end

  def edit
    @stores = current_user.group.stores
    @staffs = Staff.where(group_id:current_user.group_id,status:0,employment_status:1)
    @all_staffs = Staff.where(group_id:current_user.group_id,status:0)

  end

  def create

    @weekly_report = WeeklyReport.new(weekly_report_params)
    respond_to do |format|
      if @weekly_report.save
        report=" *予算* ：円\n"+
        " *memo* ：\n\n"+
        "ーーーーー\n"
        if params[:weekly_report]["slack_notify"]=="1"
          
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'おつかれ様', icon_emoji: ':male-farmer:').ping(report)
          # Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'おつかれ様', icon_emoji: ':male-farmer:').ping(report)
        end

        if @weekly_report.weekly_report_thanks.present?
          @weekly_report.weekly_report_thanks.each do |wrt|
            kindess_message = "ーーーー\n<@#{wrt.staff.slack_id}> \n#{wrt.thanks}（#{@weekly_report.staff.name} さんから）\nーーーーー"
            if params[:weekly_report]["slack_notify"]=="1"
              Slack::Notifier.new("https://hooks.slack.com/services/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", username: '感謝', icon_emoji: ':hugging_face:').ping(kindess_message)
              # Slack::Notifier.new("https://hooks.slack.com/services/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", username: '感謝', icon_emoji: ':hugging_face:').ping(kindess_message)
            end

          end
        end
        format.html { redirect_to weekly_reports_path(store_id:@weekly_report.store_id), success: "保存しました。" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @weekly_report.update(weekly_report_params)
        format.html { redirect_to weekly_report_url(@weekly_report), notice: "Weekly report was successfully updated." }
        format.json { render :show, status: :ok, location: @weekly_report }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @weekly_report.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @weekly_report.destroy

    respond_to do |format|
      format.html { redirect_to weekly_reports_url, notice: "Weekly report was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_weekly_report
      @weekly_report = WeeklyReport.find(params[:id])
    end

    def weekly_report_params
      params.require(:weekly_report).permit(:store_id,:staff_id,:date,:goal,:plan,:do,:check,:action,
      weekly_report_thanks_attributes:[:id,:weekly_report_id,:staff_id,:thanks,:_destroy])
    end
end


