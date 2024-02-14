class TemporaryMenuMaterialsController < AdminController
  before_action :set_temporary_menu_material, only: %i[ show edit update destroy ]

  def ikkatsu_update
    menu_material_id = params['menu_material_id']
    menu_material = MenuMaterial.find(menu_material_id)
    new_arr = []
    update_arr = []
    dates = params["temporary_menu_material"].keys
    tmms_hash = TemporaryMenuMaterial.where(menu_material_id:menu_material_id,date:dates).map{|tmm|[tmm.date,tmm]}.to_h
    params["temporary_menu_material"].each do |temporary_menu_material_params|
      date = temporary_menu_material_params[0].to_date
      # 既存のtmmがあるかどうか？
      temporary_menu_material = tmms_hash[date]

      material_id = temporary_menu_material_params[1]["material_id"]
      memo = temporary_menu_material_params[1]["memo"]
      if material_id.present?
        if temporary_menu_material.present?
          temporary_menu_material.material_id = material_id
          temporary_menu_material.memo = memo
          update_arr << temporary_menu_material
        else
          new_arr << TemporaryMenuMaterial.new(date:date,material_id:material_id,menu_material_id:menu_material_id,origin_material_id:menu_material.material_id,memo:memo)
        end
      else
        temporary_menu_material.destroy if temporary_menu_material.present?
      end
    end
    TemporaryMenuMaterial.import update_arr, on_duplicate_key_update:[:material_id,:memo]
    TemporaryMenuMaterial.import new_arr
    redirect_to new_temporary_menu_material_path(menu_material_id:menu_material_id),success:'情報を更新しました。'
  end
  def index
    if params[:start_date].present?
      date = params[:start_date].to_date
    else
      date = @today
    end
    @dates = (date.beginning_of_month..date.end_of_month).to_a
    @temporary_menu_materials = TemporaryMenuMaterial.includes(:material,menu_material:[:material,:menu]).where(date:@dates)
    menu_ids = @temporary_menu_materials.map{|tmm|tmm.menu_material.menu_id}.uniq
    product_ids = ProductMenu.where(menu_id:menu_ids).map{|pm|pm.product_id}.uniq
    @hhash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @calendar_hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @temporary_menu_materials.each do |tmm|
      @hash[tmm.date][tmm.menu_material_id][:material_id] = tmm.material_id
      @hash[tmm.date][tmm.menu_material_id][:origin_material_id] = tmm.origin_material_id
      @hash[tmm.date][tmm.menu_material_id][:material] = tmm.material
      @hash[tmm.date][tmm.menu_material_id][:menu] = tmm.menu_material.menu
      @hash[tmm.date][tmm.menu_material_id][:menu_material_id] = tmm.menu_material_id
      @hash[tmm.date][tmm.menu_material_id][:memo] = tmm.memo
    end
    DailyMenuDetail.includes(:daily_menu,product:[menus:[:menu_materials]]).joins(:daily_menu).where(:daily_menus =>{start_time:@dates}).where(product_id:product_ids).each do |dmd|
      dmd.product.menus.each do |menu|
        menu.menu_materials.each do |mm|
          if @hash[dmd.daily_menu.start_time][mm.id].present?
            if @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]].present?
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:amount_used] += ((dmd.manufacturing_number * mm.amount_used)/@hash[dmd.daily_menu.start_time][mm.id][:material].recipe_unit_quantity)*@hash[dmd.daily_menu.start_time][mm.id][:material].order_unit_quantity
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:menus][menu.id] = @hash[dmd.daily_menu.start_time][mm.id][:menu]
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:menu_materials][mm.id][:name] = mm.menu.name
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:menu_materials][mm.id][:amount] = ((dmd.manufacturing_number * mm.amount_used)/@hash[dmd.daily_menu.start_time][mm.id][:material].recipe_unit_quantity)*@hash[dmd.daily_menu.start_time][mm.id][:material].order_unit_quantity
            else
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:memo] = @hash[dmd.daily_menu.start_time][mm.id][:memo]
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:amount_used]= ((dmd.manufacturing_number * mm.amount_used)/@hash[dmd.daily_menu.start_time][mm.id][:material].recipe_unit_quantity)*@hash[dmd.daily_menu.start_time][mm.id][:material].order_unit_quantity
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:order_unit]= @hash[dmd.daily_menu.start_time][mm.id][:material].order_unit
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:material]= @hash[dmd.daily_menu.start_time][mm.id][:material]
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:menus][menu.id]= @hash[dmd.daily_menu.start_time][mm.id][:menu]
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:menu_materials][mm.id][:name] = mm.menu.name
              @hhash[dmd.daily_menu.start_time][@hash[dmd.daily_menu.start_time][mm.id][:material_id]][:menu_materials][mm.id][:amount] = ((dmd.manufacturing_number * mm.amount_used)/@hash[dmd.daily_menu.start_time][mm.id][:material].recipe_unit_quantity)*@hash[dmd.daily_menu.start_time][mm.id][:material].order_unit_quantity
             end
          end
        end
      end
    end
    @daily_menus = DailyMenu.where(start_time:@dates).map{|dm|[dm.start_time,dm]}.to_h
  end

  def material_date
    material_id = params[:material_id]
    @date = params[:date]
    @material = Material.find(material_id)

    menu_ids = Menu.joins(:materials).where(:materials=>{id:material_id}).ids
    product_ids = Product.joins(:product_menus).where(:product_menus=>{menu_id:menu_ids}).ids
    @dmds = DailyMenuDetail.joins(:daily_menu).where(:daily_menus =>{start_time:@date}).where(product_id:product_ids)
    # @dmds_hash = DailyMenuDetail.joins(:daily_menu).where(:daily_menus =>{start_time:@date}).where(product_id:product_ids).map{|dmd|[dmd.daily_menu.start_time,dmd]}.to_h
    menu_ids = ProductMenu.where(product_id:@dmds.map{|dmd|dmd.product_id}).map{|pm|pm.menu_id}
    @menu_materials = MenuMaterial.includes([:material,:menu]).where(menu_id:menu_ids,material_id:material_id)
    @tmm_hash = TemporaryMenuMaterial.where(origin_material_id:material_id,date:@date).map{|tmm|[tmm.menu_material_id,tmm]}.to_h
    dmds = DailyMenuDetail.includes(:product).joins(:daily_menu).where(:daily_menus =>{start_time:@date}).where(product_id:product_ids)
    @hash = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    dmds.each do |dmd|
      MenuMaterial.includes([:material,:menu]).where(menu_id:dmd.product.menus.ids,material_id:material_id).each do |mm|
        @hash[@date][mm.id][:amount] = (mm.amount_used * dmd.manufacturing_number).round.to_s(:delimited)
        @hash[@date][mm.id][:num] = dmd.manufacturing_number
      end
    end
  end

  def show
  end

  def new
    if params[:date].present?
      @date = Date.parse(params[:date])
    else
      @date = @today
    end
    @dates = (@date.beginning_of_month..@date.end_of_month).to_a
    @next = @date.next_month
    @last = @date.last_month
    @menu_material = MenuMaterial.find(params[:menu_material_id])
    product_ids = Product.joins(:product_menus).where(:product_menus=>{menu_id:@menu_material.menu_id}).ids
    dmds = DailyMenuDetail.joins(:daily_menu).where(:daily_menus =>{start_time:@dates}).where(product_id:product_ids)
    @dmds_hash = DailyMenuDetail.includes(:daily_menu).joins(:daily_menu).where(:daily_menus =>{start_time:@dates}).where(product_id:product_ids).map{|dmd|[dmd.daily_menu.start_time,dmd]}.to_h
    # dms = DailyMenu.where(start_time:@dates).joins(:daily_menu_details).where(:daily_menu_details =>{product_id:product_ids})
    @temporary_menu_materials = TemporaryMenuMaterial.where(date:@dates,menu_material_id:@menu_material.id)
    material_ids = @temporary_menu_materials.map{|tmm|tmm.material_id}
    @materials = Material.includes(:vendor).where(unused_flag:false).map{|material|["#{material.name}｜#{material.vendor.name}",material.id]}
    @hash = @temporary_menu_materials.map{|tmm|[tmm.date,tmm]}.to_h
  end

  def edit
  end

  def create
    @temporary_menu_material = TemporaryMenuMaterial.new(temporary_menu_material_params)

    respond_to do |format|
      if @temporary_menu_material.save
        format.html { redirect_to temporary_menu_material_url(@temporary_menu_material), notice: "Temporary menu material was successfully created." }
        format.json { render :show, status: :created, location: @temporary_menu_material }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @temporary_menu_material.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @temporary_menu_material.update(temporary_menu_material_params)
        format.html { redirect_to temporary_menu_material_url(@temporary_menu_material), notice: "Temporary menu material was successfully updated." }
        format.json { render :show, status: :ok, location: @temporary_menu_material }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @temporary_menu_material.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @temporary_menu_material.destroy

    respond_to do |format|
      format.html { redirect_to temporary_menu_materials_url, notice: "Temporary menu material was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_temporary_menu_material
      @temporary_menu_material = TemporaryMenuMaterial.find(params[:id])
    end

    def temporary_menu_material_params
      params.require(:temporary_menu_material).permit(:menu_material_id,:material_id,:date,:origin_material_id,:memo)
    end
end
