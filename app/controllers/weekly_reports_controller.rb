class WeeklyReportsController < ApplicationController
  before_action :set_weekly_report, only: %i[ show edit update destroy ]

  def index
    @weekly_reports = WeeklyReport.all.order('id desc')
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
        report=" *スタッフ名* ：#{@weekly_report.staff.name} \n\n"+
        " *日付* ：#{@weekly_report.date}\n\n"+
        " *店舗* ：#{@weekly_report.store.short_name}\n\n"+
        " *P：今週の目標・計画*\n#{@weekly_report.plan}\n\n"+
        " *D：実行したこと*\n#{@weekly_report.do}\n\n"+
        " *C：振り返り・結果*\n#{@weekly_report.check}\n\n"+
        " *A：次週のアクション*\n#{@weekly_report.action}\n\n"+
        "ーーーーー\n"
        if params[:weekly_report]["slack_notify"]=="1"
          # Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'おつかれ様', icon_emoji: ':male-farmer:').ping(report)
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'おつかれ様', icon_emoji: ':male-farmer:').ping(report)
        end
        if @weekly_report.weekly_report_thanks.present?
          @weekly_report.weekly_report_thanks.each do |wrt|
            kindess_message = "<@#{wrt.staff.slack_id}> \n#{wrt.thanks}（<@#{@weekly_report.staff.slack_id}> さんから）\nーーーーー"
            if params[:weekly_report]["slack_notify"]=="1"
              # Slack::Notifier.new("https://hooks.slack.com/services/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", username: '感謝', icon_emoji: ':hugging_face:').ping(kindess_message)
              Slack::Notifier.new("https://hooks.slack.com/services/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", username: '感謝', icon_emoji: ':hugging_face:').ping(kindess_message)
            end
          end
        end
        format.html { redirect_to weekly_reports_path, success: "保存しました。" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @weekly_report.update(weekly_report_params)
        report=" *スタッフ名* ：#{@weekly_report.staff.name} \n\n"+
        " *日付* ：#{@weekly_report.date}\n\n"+
        " *店舗* ：#{@weekly_report.store.short_name}\n\n"+
        " *P：今週の目標・計画*\n#{@weekly_report.plan}\n\n"+
        " *D：実行したこと*\n#{@weekly_report.do}\n\n"+
        " *C：振り返り・結果*\n#{@weekly_report.check}\n\n"+
        " *A：次週のアクション*\n#{@weekly_report.action}\n\n"+
        "ーーーーー\n"
        if params[:weekly_report]["slack_notify"]=="1"
          # Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'おつかれ様', icon_emoji: ':male-farmer:').ping(report)
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'おつかれ様', icon_emoji: ':male-farmer:').ping(report)
        end
        if @weekly_report.weekly_report_thanks.present?
          @weekly_report.weekly_report_thanks.each do |wrt|
            kindess_message = "<@#{wrt.staff.slack_id}> \n#{wrt.thanks}（<@#{@weekly_report.staff.slack_id}> さんから）\nーーーーー"
            if params[:weekly_report]["slack_notify"]=="1"
              # Slack::Notifier.new("https://hooks.slack.com/services/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", username: '感謝', icon_emoji: ':hugging_face:').ping(kindess_message)
              Slack::Notifier.new("https://hooks.slack.com/services/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", username: '感謝', icon_emoji: ':hugging_face:').ping(kindess_message)
            end
          end
        end
        format.html { redirect_to weekly_reports_path, notice: "Weekly report was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
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


