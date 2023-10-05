class AnalysisProductsController < AdminController
  before_action :set_analysis_product, only: %i[ show edit update destroy ]
  def index
    @analysis_products = AnalysisProduct.all
  end
  def show
  end
  def new
    @analysis_product = AnalysisProduct.new
  end
  def edit
  end
  def create
    @analysis_product = AnalysisProduct.new(analysis_product_params)

    respond_to do |format|
      if @analysis_product.save
        format.html { redirect_to @analysis_product, notice: "Analysis product was successfully created." }
        format.json { render :show, status: :created, location: @analysis_product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @analysis_product.errors, status: :unprocessable_entity }
      end
    end
  end
  def update
    @class_name = ".analysis_product_tr_#{@analysis_product.id}"
    respond_to do |format|
      if @analysis_product.update(analysis_product_params)
        format.html { redirect_to @analysis_product, notice: "Analysis product was successfully updated." }
        format.json { render :show, status: :ok, location: @analysis_product }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @analysis_product.errors, status: :unprocessable_entity }
      end
    end
  end
  def destroy
    @analysis_product.destroy
    respond_to do |format|
      format.html { redirect_to analysis_products_url, notice: "Analysis product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_analysis_product
      @analysis_product = AnalysisProduct.find(params[:id])
    end

    def analysis_product_params
      params.require(:analysis_product).permit(:id,:exclusion_flag)
    end
end
