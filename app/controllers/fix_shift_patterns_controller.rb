class FixShiftPatternsController < AdminController
  before_action :set_fix_shift_pattern, only: %i[ show edit update destroy ]

  def index
    @fix_shift_patterns = FixShiftPattern.includes(fix_shift_pattern_stores:[:store],fix_shift_pattern_shift_frames:[:shift_frame]).all.order(:pattern_name)
  end

  def show
  end

  def new
    group_id = current_user.group_id
    @group = Group.find(group_id)
    @stores = @group.stores
    @shift_frames = ShiftFrame.where(group_id:group_id)
    @fix_shift_pattern = FixShiftPattern.new(group_id:group_id)
    @fix_shift_pattern.fix_shift_pattern_stores.build
  end

  def edit
    @group = @fix_shift_pattern.group
    @stores = @group.stores
    @shift_frames = ShiftFrame.where(group_id:@group.id)
  end

  def create
    @fix_shift_pattern = FixShiftPattern.new(fix_shift_pattern_params)
    respond_to do |format|
      if @fix_shift_pattern.save
        format.html { redirect_to fix_shift_patterns_path, success: "更新しました" }
        format.json { render :show, status: :created, location: @fix_shift_pattern }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @fix_shift_pattern.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @fix_shift_pattern.update(fix_shift_pattern_params)
        format.html { redirect_to fix_shift_patterns_path, success: "更新しました" }
        format.json { render :show, status: :ok, location: @fix_shift_pattern }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @fix_shift_pattern.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @fix_shift_pattern.destroy
    respond_to do |format|
      format.html { redirect_to fix_shift_patterns_url, notice: "Fix shift pattern was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_fix_shift_pattern
      @fix_shift_pattern = FixShiftPattern.find(params[:id])
    end

    def fix_shift_pattern_params
      params.require(:fix_shift_pattern).permit(:shift_frame_id,:group_id,:pattern_name,:working_hour,:end_time,:start_time,
        :group_id,:color_code,:bg_color_code,:unused_flag,:rest_start_time,:rest_end_time,
      fix_shift_pattern_shift_frames_attributes: [:id, :fix_shift_pattern_id,:shift_frame_id,:_destroy],
      fix_shift_pattern_stores_attributes: [:id, :fix_shift_pattern_id,:store_id,:_destroy])
    end
end
