class StaffsController < ApplicationController
  before_action :set_staff, only: %i[ show edit update destroy ]
  def row_order_update
    staffs_arr = []
    staffs = Staff.all
    group_id = params[:group_id]
    staffs.each do |staff|
      staff.row = params['row'][staff.id.to_s].to_i
      staffs_arr << staff
    end
    Staff.import staffs_arr, :on_duplicate_key_update => [:row]
    redirect_to staffs_path(group_id:group_id),notice:'並び更新しました。'
  end
  def index
    group_id = params[:group_id]
    @group = Group.find(group_id)
    if params[:status].present?
      status = params[:status]
    else
      status = 0
    end
    if params[:store_type].present?
      @stores = @group.stores.where(store_type:params[:store_type])
      staff_ids = @stores.map{|store|store.staffs.ids}.flatten.uniq
      @staffs = Staff.where(id:staff_ids,status:status).order(row:'asc')
    else
      @staffs = Staff.where(group_id:group_id,status:status).order(row:'asc')
    end
  end

  def show
  end

  def new
    @group = Group.find(params[:group_id])
    @stores = @group.stores
    if params[:place] == 'kitchen'
      @staff = Staff.new(store_id:39,group_id:@group.id)
    else
      @staff = Staff.new(group_id:@group.id)
    end
    @stores.each do |store|
      @staff.staff_stores.build(store_id:store.id)
    end

  end

  def edit
    Store.where(group_id:current_user.group_id).where.not(id:@staff.staff_stores.map{|ss|ss.store_id}).each do |store|
      @staff.staff_stores.build(store_id:store.id)
    end
  end

  def create
    @staff = Staff.new(staff_params)
    respond_to do |format|
      if @staff.save
        format.html { redirect_to staffs_path(group_id:@staff.group_id), notice: "Staff was successfully created." }
        format.json { render :show, status: :created, location: @staff }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @staff.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @staff.update(staff_params)
        format.html { redirect_to staffs_path(group_id:@staff.group_id), notice: "Staff was successfully updated." }
        format.json { render :show, status: :ok, location: @staff }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @staff.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @staff.destroy
    respond_to do |format|
      format.html { redirect_to staffs_url, notice: "Staff was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_staff
      @staff = Staff.find(params[:id])
    end

    def staff_params
      params.require(:staff).permit(:store_id,:name,:memo,:employment_status,:row,:status,:staff_code,:smaregi_hanbaiin_id,:phone_number,:group_id,
        staff_stores_attributes:[:id,:store_id,:staff_id,:affiliation_flag,:transportation_expenses,:_destroy])
    end
end
