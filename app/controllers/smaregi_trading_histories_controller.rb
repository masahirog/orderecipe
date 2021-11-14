class SmaregiTradingHistoriesController < AdminController
  before_action :set_smaregi_trading_history, only: %i[ show edit update destroy ]
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
      sm.raiten_kaisu = sm.raiten_kaisu - kaiin_raitensu_hash[sm.kaiin_id]
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
  # def index
  #   @analysis_id = params[:analysis_id]
  #   @analysis = Analysis.find(@analysis_id) if @analysis_id
  #   @shohin_id = params[:shohin_id]
  #   @hinban = params[:hinban]
  #   @shohinmei = params[:shohinmei]
  #   @smaregi_trading_histories = SmaregiTradingHistory.all
  #   @smaregi_trading_histories = @smaregi_trading_histories.where(analysis_id:@analysis_id) if @analysis_id.present?
  #   @shohin_ids = @smaregi_trading_histories.map{|sth|sth.shohin_id}.uniq
  #   @product_ids = @smaregi_trading_histories.map{|sth|sth.hinban}.uniq
  #   @shohinmeis = @smaregi_trading_histories.map{|sth|sth.shohinmei}.uniq
  #   @smaregi_trading_histories = @smaregi_trading_histories.where(shohin_id:@shohin_id) if @shohin_id.present?
  #   @smaregi_trading_histories = @smaregi_trading_histories.where(hinban:@hinban) if @hinban.present?
  #   @smaregi_trading_histories = @smaregi_trading_histories.where(shohinmei:@shohinmei) if @shohinmei.present?
  #   @date_counts = @smaregi_trading_histories.group(:date).count()
  # end

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
