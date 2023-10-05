class WorkingHoursController < AdminController
  before_action :set_working_hour, only: %i[ show edit update destroy ]
  def result
    today = Date.today
    @group = Group.find(19)
    @staffs = WorkingHour.where(group_id:@group.id).pluck(:name).uniq
    if params[:from]
      @from = params[:from]
    else
      @from = today - 30
    end
    if params[:to]
      @to = params[:to]
    else
      @to = today
    end
    @working_hours = WorkingHour.where(date:@from..@to).where(group_id:@group.id)
    @working_hours = @working_hours.group(:date).sum(:working_time)
    @kari_working_time = @working_hours.group(:date).sum(:kari_working_time)
    @chori_of_working_time = @working_hours.group(:date).sum(:chori_of_working_time)
    @kiridashi_of_working_time = @working_hours.group(:date).sum(:kiridashi_of_working_time)
    @moritsuke_of_working_time = @working_hours.group(:date).sum(:moritsuke_of_working_time)
    @sekisai_of_working_time = @working_hours.group(:date).sum(:sekisai_of_working_time)
    @sonota_of_working_time = @working_hours.group(:date).sum(:sonota_of_working_time)
    @tare_of_working_time = @working_hours.group(:date).sum(:tare_of_working_time)
    @washing_of_working_time = @working_hours.group(:date).sum(:washing_of_working_time)

  end
  def staff_input
    today = Date.today
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = today
    end
    if params[:staff_id].present?
      if params[:alert_flag] == "true"
        @working_hours = []
        WorkingHour.where(staff_id:params[:staff_id]).where("date > ?",'2022/11/16').where("working_time > ?",0).each do |wh|
          if (wh.working_time.to_f - wh.kari_working_time.to_f).abs > 1
            @working_hours << wh
          end
        end
      else
        @working_hours = WorkingHour.where(staff_id:params[:staff_id]).where("date > ?",'2022/11/16').where("working_time > ?",0)
      end
    else
      @working_hours = WorkingHour.where(date:@date).where(group_id:current_user.group_id)
    end
    @times = []
    15.times do |hour|
      [["00",0.0],["15",0.25],["30",0.5],["45",0.75]].each do |min|
        @times  << ["#{hour}:#{min[0]}",(hour + min[1])]
      end
    end
    @staff_working_hours = {}
    WorkingHour.where("date > ?",'2022/11/16').where("working_time > ?",0).each do |wh|
      if (wh.working_time.to_f - wh.kari_working_time.to_f).abs > 1
        if @staff_working_hours[wh.staff_id].present?
          @staff_working_hours[wh.staff_id] << wh
        else
          @staff_working_hours[wh.staff_id] = [wh]
        end
      end
    end
  end
  def create_work_times
    new_arr = []
    @date = Date.parse(params[:date])
    working_hour_hash = WorkingHour.where(date:params[:date]).map{|wh|[[wh.date,wh.staff_id],wh]}.to_h
    Staff.where(group_id:current_user.group_id,employment_status:1,status:0).where(status:0).each do |staff|
      if working_hour_hash[[@date,staff.id]].present?
      else
        new_arr << WorkingHour.new(date:@date,group_id:current_user.group_id,staff_id:staff.id,name:staff.name,store_id:39)
      end
    end
    WorkingHour.import new_arr
    redirect_to staff_input_working_hours_path(date:@date,group_id:current_user.group_id)
  end

  def upload_data
    group_id = params[:group_id]
    WorkingHour.upload_data(params[:file],group_id)
    redirect_to working_hours_path(group_id:group_id), :notice => "ジョブカンデータをアップロードしました。"
  end

  def index
    today = Date.today
    @group = Group.find(params[:group_id])
    @staffs = WorkingHour.where(group_id:@group.id).pluck(:name).uniq
    if params[:from]
      @from = params[:from]
    else
      @from = today
    end
    if params[:to]
      @to = params[:to]
    else
      @to = today
    end
    @working_hours = WorkingHour.where(date:@from..@to).where(group_id:@group.id)
    @working_hours = @working_hours.where(name:params[:name]) if params[:name].present?
    @working_hours = @working_hours.page(params[:page]).per(50)
  end

  def show
  end

  def new
    @working_hour = WorkingHour.new
  end

  def edit
  end

  def create
    @working_hour = WorkingHour.new(working_hour_params)

    respond_to do |format|
      if @working_hour.save
        format.html { redirect_to working_hour_url(@working_hour), notice: "Working hour was successfully created." }
        format.json { render :show, status: :created, location: @working_hour }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @working_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @position = params["working_hour"]["position"]
    respond_to do |format|
      if @working_hour.update(working_hour_params)
        columns = [:chori_of_working_time,:kiridashi_of_working_time,:moritsuke_of_working_time,:sekisai_of_working_time,:tare_of_working_time,:washing_of_working_time,:sonota_of_working_time]
        kari_working_time = columns.map { |c| @working_hour.send(c).to_f }.sum
        @working_hour.update(kari_working_time:kari_working_time)
        format.html
        format.js
      else
        format.html
        format.js
      end
    end
  end

  def destroy
    @working_hour.destroy
    respond_to do |format|
      format.html { redirect_to working_hours_url, notice: "Working hour was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_working_hour
      @working_hour = WorkingHour.find(params[:id])
    end

    def working_hour_params
      params.require(:working_hour).permit(:id,:date,:name,:working_time,:store_id,:group_id,:position,
      :kari_working_time,:chori_of_working_time,:kiridashi_of_working_time,:moritsuke_of_working_time,:sekisai_of_working_time,
      :sonota_of_working_time,:tare_of_working_time,:washing_of_working_time)

    end
end
