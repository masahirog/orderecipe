class SmaregiTradingHistoriesController < AdminController
  before_action :set_smaregi_trading_history, only: %i[ show edit update destroy ]
  def member
    if params[:store_ids].present?
      params[:stores] = {}
      checked_store_ids = params['store_ids']
      @stores = Store.where(id:checked_store_ids)
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    elsif params[:stores].present?
      checked_store_ids = params['stores'].keys
      @stores = Store.where(id:checked_store_ids)
      params[:store_ids] = checked_store_ids
    else
      params[:stores] = {}
      @stores = Store.where(group_id:9).where.not(id:39)
      checked_store_ids = @stores.ids
      params[:store_ids] = checked_store_ids
      @stores.each do |store|
        params[:stores][store.id.to_s] = true
      end
    end
    @smaregi_members = SmaregiMember.where(main_use_store:@stores.map{|store|store.smaregi_store_id})
    if params[:order].present?
      @smaregi_members = @smaregi_members.order("#{params[:order]} #{params[:sc]}")
    end
    @smaregi_members = @smaregi_members.page(params[:page]).per(50)
    kaiin_ids = @smaregi_members.map{|sm|sm.kaiin_id}
    @smaregi_trading_histories = SmaregiTradingHistory.where(kaiin_id:kaiin_ids)
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "member.csv", type: :csv
      end
    end    
  end

  def bulk_delete
    update_smaregi_members_arr = []
    analysis_id = params[:analysis_id]
    analysis = Analysis.find(analysis_id)
    @smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analysis_id)
    count = @smaregi_trading_histories.count

    # 会員の来店数更新
    kaiin_raitensu_hash = @smaregi_trading_histories.where.not(kaiin_id: nil).where(torihikimeisai_id:1,torihiki_meisaikubun:1).group(:kaiin_id).count
    kaiin_ids = @smaregi_trading_histories.map{|sth|sth.kaiin_id}.uniq.compact
    orderecipe_saved_smaregi_members = SmaregiMember.where(kaiin_id:kaiin_ids)
    orderecipe_saved_smaregi_members_kaiin_ids = orderecipe_saved_smaregi_members.map{|ossm|ossm.kaiin_id}
    last_store_date = SmaregiTradingHistory.where.not(analysis_id:analysis_id).where(kaiin_id:orderecipe_saved_smaregi_members_kaiin_ids).where(torihiki_meisaikubun:1,torihikimeisai_id:1,uchikeshi_kubun:0).order(date:"asc").map{|sth|[sth.kaiin_id,sth.date]}.to_h
    orderecipe_saved_smaregi_members.each do |sm|
      sm.raiten_kaisu = sm.raiten_kaisu - kaiin_raitensu_hash[sm.kaiin_id].to_i
      sm.last_visit_store = last_store_date[sm.kaiin_id]
      update_smaregi_members_arr << sm
    end
    SmaregiMember.import update_smaregi_members_arr, on_duplicate_key_update:[:raiten_kaisu,:last_visit_store]

    @smaregi_trading_histories.destroy_all
    redirect_to analysis, :alert => "#{count}件を削除しました。"
  end
  def analysis_data
    analysis_id = params[:analysis_id]
    shohin_id = params[:shohin_id]
    hinban = params[:hinban]
    shohinmei = params[:shohinmei]
    @smaregi_trading_histories = SmaregiTradingHistory.where(analysis_id:analysis_id)
  end

  def upload_salesdatas
    date = params[:date]
    smaregi_store_id = params[:smaregi_store_id]
    analysis_id = params[:analysis_id]
    update_datas_count = SmaregiTradingHistory.upload_data(date,smaregi_store_id,analysis_id,params[:file])
    if update_datas_count == 'false'
      redirect_to smaregi_trading_histories_path(), :alert => 'csvデータが正しいかどうか確認してください'
    else
      redirect_to analysis_path(id:analysis_id), :notice => "#{update_datas_count}件の取引履歴をアップロードしました。"
    end
  end

  def once_upload_salesdatas
    date = params[:date]
    smaregi_store_id = params[:smaregi_store_id]
    analysis_id = params[:analysis_id]
    update_datas_count = SmaregiTradingHistory.upload_data(date,smaregi_store_id,analysis_id,params[:file])
    if update_datas_count == 'false'
      redirect_to smaregi_trading_histories_path(), :alert => 'csvデータが正しいかどうか確認してください'
    else
      redirect_to analysis_path(id:analysis_id), :notice => "#{update_datas_count}件の取引履歴をアップロードしました。"
    end
  end

  def index
    @shohinmeis = SmaregiTradingHistory.pluck(:shohinmei).uniq
    @to = Date.today
    @from = Date.today - 30
    @to = Date.parse(params[:to]) if params[:to]
    @from = Date.parse(params[:from]) if params[:from]
    @smaregi_trading_histories = SmaregiTradingHistory.where(date:@from..@to)
    @smaregi_trading_histories = @smaregi_trading_histories.where(shohin_id:params[:shohin_id]) if params[:shohin_id].present?
    @smaregi_trading_histories = @smaregi_trading_histories.where(shohinmei:params[:shohinmei]) if params[:shohinmei].present?
    respond_to do |format|
      format.html do
        @count = @smaregi_trading_histories.count
        @smaregi_trading_histories = @smaregi_trading_histories.page(params[:page]).per(100)
        # if @count > 10000
        #   @smaregi_trading_histories = []
        # else
        #   @smaregi_trading_histories = @smaregi_trading_histories.page(params[:page]).per(100)
        # end
      end
      format.csv do
        if @smaregi_trading_histories.count > 10000
          #1万件以上のときはhtmlにリダイレクト
          redirect_to smaregi_trading_histories_path
        else
          @smaregi_trading_histories = @smaregi_trading_histories
          send_data render_to_string, filename: "smaregi_trading_histories.csv", type: :csv
        end
      end
    end

  end

  def show
  end

  def new
    @smaregi_trading_history = SmaregiTradingHistory.new
  end

  def edit
  end

  def create
    @smaregi_trading_history = SmaregiTradingHistory.new(smaregi_trading_history_params)

    respond_to do |format|
      if @smaregi_trading_history.save
        format.html { redirect_to @smaregi_trading_history, notice: "SmaregiTradingHistory was successfully created." }
        format.json { render :show, status: :created, location: @smaregi_trading_history }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @smaregi_trading_history.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @class_name = ".sth_" + @smaregi_trading_history.id.to_s
    respond_to do |format|
      if @smaregi_trading_history.update(smaregi_trading_history_params)
        format.js
        format.html { redirect_to @smaregi_trading_history, notice: "SmaregiTradingHistory was successfully updated." }
        format.json { render :show, status: :ok, location: @smaregi_trading_history }
      else
        format.js
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @smaregi_trading_history.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @smaregi_trading_history.destroy
    respond_to do |format|
      format.html { redirect_to smaregi_trading_histories_url, notice: "SmaregiTradingHistory was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_smaregi_trading_history
      @smaregi_trading_history = SmaregiTradingHistory.find(params[:id])
    end

    def smaregi_trading_history_params
      params.require(:smaregi_trading_history).permit(:torihiki_id,:torihiki_nichiji,:tanka_nebikimae_shokei,:tanka_nebiki_shokei,:shokei,:shikei_nebiki,:shokei_waribikiritsu,
      :point_nebiki,:gokei,:suryo_gokei,:henpinsuryo_gokei,:huyo_point,:shiyo_point,:genzai_point,:gokei_point,:tenpo_id,:kaiin_id,
      :kaiin_code,:tanmatsu_torihiki_id,:nenreiso,:kyakuso_id,:hanbaiin_id,:hanbaiin_mei,:torihikimeisai_id,:torihiki_meisaikubun,
      :shohin_id,:shohin_code,:hinban,:shohinmei,:shohintanka,:hanbai_tanka,:tanpin_nebiki,:tanpin_waribiki,:suryo,:nebikimaekei,
      :tanka_nebikikei,:nebikigokei,:bumon_id,:bumonmei)
    end
end
