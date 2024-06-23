class TemporaryProductMenusController < ApplicationController
  before_action :set_temporary_product_menu, only: %i[ show edit update destroy ]

  def ikkatsu_update
    menu_id = params['menu_id']
    new_arr = []
    update_arr = []
    daily_menu_detail_ids = params["temporary_product_menu"].keys
    tpms_hash = TemporaryProductMenu.where(daily_menu_detail_id:daily_menu_detail_ids).map{|tpm|[[tpm.daily_menu_detail_id,tpm.product_menu_id],tpm]}.to_h

    params["temporary_product_menu"].each do |data|
      data[1].each do |pm_data|
        changed_menu_id = pm_data[1]['menu_id']
        memo = pm_data[1]['memo']
        if changed_menu_id.present?
          daily_menu_detail_id = data[0].to_i
          product_menu_id = pm_data[0].to_i
          temporary_product_menu = tpms_hash[[daily_menu_detail_id,product_menu_id]]
          if temporary_product_menu.present?
            temporary_product_menu.menu_id = changed_menu_id
            temporary_product_menu.memo = memo
            update_arr << temporary_product_menu
          else
            new_arr << TemporaryProductMenu.new(daily_menu_detail_id:daily_menu_detail_id,product_menu_id:product_menu_id,menu_id:changed_menu_id,original_menu_id:menu_id,memo:memo)
          end
        end
      end
    end
    TemporaryProductMenu.import update_arr, on_duplicate_key_update:[:menu_id,:memo]
    TemporaryProductMenu.import new_arr
    redirect_to new_temporary_product_menu_path(menu_id:menu_id),success:'情報を更新しました。'
  end



  def index
    if params[:start_date].present?
      date = params[:start_date].to_date
    else
      date = @today
    end
    @dates = (date.beginning_of_month..date.end_of_month).to_a
    daily_menus = DailyMenu.where(start_time:@dates)
    daily_menu_detail_ids = DailyMenuDetail.where(daily_menu_id:daily_menus.ids).map{|dmd|dmd.id}
    @temporary_product_menus = TemporaryProductMenu.where(daily_menu_detail_id:daily_menu_detail_ids)
    @menu_hash = Menu.where(id:@temporary_product_menus.map{|tpm|tpm.menu_id}.uniq).map{|menu|[menu.id,menu]}.to_h
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @temporary_product_menus.each do |tpm|
      @hash[tpm.daily_menu_detail.daily_menu.id][tpm.menu_id][:original_menu] = Menu.find(tpm.original_menu_id)
      @hash[tpm.daily_menu_detail.daily_menu.id][tpm.menu_id][:menu] = @menu_hash[tpm.menu_id]
      @hash[tpm.daily_menu_detail.daily_menu.id][tpm.menu_id][:product_menus][tpm.product_menu_id] = tpm
    end
    product_menu_ids = @temporary_product_menus.map{|tpm|tpm.product_menu_id}.uniq
    @daily_menus = DailyMenu.where(start_time:@dates).map{|dm|[dm.start_time,dm]}.to_h
  end

  def show
  end

  def new
    if params[:date].present?
      @date = Date.parse(params[:date])
    else
      @date = @today
    end
    if @date.wday == 3
      @from = @date
      @to = @from + 6
    else
      number = {"0"=>4,"1"=>5,"2"=>6,"4"=>1,"5"=>2,"6"=>3}
      @from = @date - number[@date.wday.to_s]
      @to = @from + 6
    end
    @dates = (@from..@to).to_a
    @next = @to + 1
    @last = @from - 7
    @menu = Menu.find(params[:menu_id])
    product_ids = Product.joins(:product_menus).where(:product_menus=>{menu_id:params[:menu_id]}).ids
    dmds = DailyMenuDetail.joins(:daily_menu).where(:daily_menus =>{start_time:@dates}).where(product_id:product_ids)
    @dmds_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    DailyMenuDetail.includes(:daily_menu,:product).joins(:daily_menu).order("daily_menus.start_time").where(:daily_menus =>{start_time:@dates}).where(product_id:product_ids).each do |dmd|
      dmd.product.product_menus.where(menu_id:params[:menu_id]).each do |pm|
        @dmds_hash[dmd.daily_menu.start_time][dmd.id][pm.id] = pm
      end
    end
    @temporary_product_menus = TemporaryProductMenu.where(original_menu_id:params[:menu_id])
    @menus = Menu.all.map{|menu|["#{menu.name}",menu.id]}
    @hash = @temporary_product_menus.map{|tpm|[[tpm.daily_menu_detail_id,tpm.product_menu_id],tpm]}.to_h
  end

  def edit
  end

  def create
    @temporary_product_menu = TemporaryProductMenu.new(temporary_product_menu_params)

    respond_to do |format|
      if @temporary_product_menu.save
        format.html { redirect_to temporary_product_menu_url(@temporary_product_menu), notice: "Temporary product menu was successfully created." }
        format.json { render :show, status: :created, location: @temporary_product_menu }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @temporary_product_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @temporary_product_menu.update(temporary_product_menu_params)
        format.html { redirect_to temporary_product_menu_url(@temporary_product_menu), notice: "Temporary product menu was successfully updated." }
        format.json { render :show, status: :ok, location: @temporary_product_menu }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @temporary_product_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @temporary_product_menu.destroy

    respond_to do |format|
      format.html { redirect_to temporary_product_menus_url, notice: "Temporary product menu was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_temporary_product_menu
      @temporary_product_menu = TemporaryProductMenu.find(params[:id])
    end

    def temporary_product_menu_params
      params.require(:temporary_product_menu).permit(:product_menu_id,:daily_menu_detail_id,:original_menu_id,:menu_id,:memo)
    end
end
