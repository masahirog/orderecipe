class ToStoreMessagesController < ApplicationController
  before_action :set_to_store_message, only: %i[ show edit update destroy ]

  def index
    @to_store_messages = ToStoreMessage.includes(to_store_message_stores:[:store]).all.order("updated_at DESC")
  end

  def show
  end

  def new
    @to_store_message = ToStoreMessage.new
    stores = Store.where(group_id:current_user.group_id)
    @stores_hash = {}
    stores.each do |store|
      @stores_hash[store.id]=store.name
      @to_store_message.to_store_message_stores.build(store_id:store.id)
    end
  end

  def edit
    stores = Store.where(group_id:current_user.group_id)
    @stores_hash = {}
    stores.each do |store|
      @stores_hash[store.id]=store.name
    end

  end

  def create
    @to_store_message = ToStoreMessage.new(to_store_message_params)

    respond_to do |format|
      if @to_store_message.save
        if params[:to_store_message]["slack_notify"]=="1"
          store_names = @to_store_message.to_store_message_stores.where(subject_flag:true).map{|tsms|tsms.store.short_name}
          message = "店舗へのインフォメーション\n"+
          "日付：#{@to_store_message.date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[@to_store_message.date.wday]})")}\n"+
          "店舗：#{store_names.join("、")}\n\n"+
          "内容：#{@to_store_message.content}\n\n========="
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:').ping(message)
        end
        format.html { redirect_to to_store_messages_path, notice: "新規作成" }
        format.json { render :show, status: :created, location: @to_store_message }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @to_store_message.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @to_store_message.update(to_store_message_params)
        if params[:to_store_message]["slack_notify"]=="1"
          store_names = @to_store_message.to_store_message_stores.where(subject_flag:true).map{|tsms|tsms.store.short_name}
          message = "店舗へのインフォメーション\n"+
          "日付：#{@to_store_message.date.strftime("%Y/%-m/%-d (#{%w(日 月 火 水 木 金 土)[@to_store_message.date.wday]})")}\n"+
          "店舗：#{store_names.join("、")}\n\n"+
          "内容：#{@to_store_message.content}\n\n========="
          Slack::Notifier.new("https://hooks.slack.com/services/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", username: 'Bot', icon_emoji: ':male-farmer:').ping(message)
        end
        format.html { redirect_to to_store_messages_path, notice: "更新" }
        format.json { render :show, status: :ok, location: @to_store_message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @to_store_message.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @to_store_message.destroy

    respond_to do |format|
      format.html { redirect_to to_store_messages_url, notice: "To store message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_to_store_message
      @to_store_message = ToStoreMessage.find(params[:id])
    end

    def to_store_message_params
      params.require(:to_store_message).permit(:id,:date,:content,
        to_store_message_stores_attributes:[:id,:to_store_message_id,:store_id,:subject_flag,:_destroy])
    end
end
