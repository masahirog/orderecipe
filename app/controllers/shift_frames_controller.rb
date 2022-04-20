class ShiftFramesController < ApplicationController
  before_action :set_shift_frame, only: %i[ show edit update destroy ]

  def index
    @shift_frames = ShiftFrame.all
  end

  def show
  end

  def new
    @shift_frame = ShiftFrame.new
  end

  def edit
  end

  def create
    @shift_frame = ShiftFrame.new(shift_frame_params)

    respond_to do |format|
      if @shift_frame.save
        format.html { redirect_to @shift_frame, notice: "Shift frame was successfully created." }
        format.json { render :show, status: :created, location: @shift_frame }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @shift_frame.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @shift_frame.update(shift_frame_params)
        format.html { redirect_to @shift_frame, notice: "Shift frame was successfully updated." }
        format.json { render :show, status: :ok, location: @shift_frame }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @shift_frame.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @shift_frame.destroy
    respond_to do |format|
      format.html { redirect_to shift_frames_url, notice: "Shift frame was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_shift_frame
      @shift_frame = ShiftFrame.find(params[:id])
    end

    def shift_frame_params
      params.require(:shift_frame).permit(:name,:group_id)
    end
end
