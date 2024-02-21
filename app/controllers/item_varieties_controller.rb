class ItemVarietiesController < ApplicationController
  before_action :set_item_variety, only: %i[ show edit update destroy ]

  # GET /item_varieties or /item_varieties.json
  def index
    @item_varieties = ItemVariety.all
  end

  # GET /item_varieties/1 or /item_varieties/1.json
  def show
  end

  # GET /item_varieties/new
  def new
    @item_variety = ItemVariety.new
  end

  # GET /item_varieties/1/edit
  def edit
  end

  # POST /item_varieties or /item_varieties.json
  def create
    @item_variety = ItemVariety.new(item_variety_params)

    respond_to do |format|
      if @item_variety.save
        format.html { redirect_to item_variety_url(@item_variety), notice: "Item variety was successfully created." }
        format.json { render :show, status: :created, location: @item_variety }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item_variety.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /item_varieties/1 or /item_varieties/1.json
  def update
    respond_to do |format|
      if @item_variety.update(item_variety_params)
        format.html { redirect_to item_variety_url(@item_variety), notice: "Item variety was successfully updated." }
        format.json { render :show, status: :ok, location: @item_variety }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item_variety.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /item_varieties/1 or /item_varieties/1.json
  def destroy
    @item_variety.destroy

    respond_to do |format|
      format.html { redirect_to item_varieties_url, notice: "Item variety was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_variety
      @item_variety = ItemVariety.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def item_variety_params
      params.fetch(:item_variety, {})
    end
end
