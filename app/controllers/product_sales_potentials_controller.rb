class ProductSalesPotentialsController < AdminController
  before_action :set_product_sales_potential, only: %i[ show edit update destroy ]
  def reflesh
    create_arr = []
    update_arr = []
    product_ids = params[:product_ids]
    store_id = params[:store_id]
    product_ids.each do |product_id|
      sales_potential = ProductSalesPotential.recalculate_potential(store_id,product_id)
      product_sales_potential = ProductSalesPotential.find_by(store_id:store_id,product_id:product_id)
      if product_sales_potential.present?
        product_sales_potential.sales_potential = sales_potential
        update_arr << product_sales_potential
      else
        create_arr << ProductSalesPotential.new(store_id:store_id,product_id:product_id,sales_potential:sales_potential)
      end
    end
    ProductSalesPotential.import update_arr,on_duplicate_key_update:[:sales_potential]
    ProductSalesPotential.import create_arr
    redirect_to input_manufacturing_number_store_daily_menus_path(store_id:store_id,store_daily_menu_ids: params["store_daily_menu_ids"])
  end
  def index
    @product_sales_potentials = ProductSalesPotential.all
  end
  def show
  end
  def new
    @product_sales_potential = ProductSalesPotential.new
  end
  def edit
  end
  def create
    @product_sales_potential = ProductSalesPotential.new(product_sales_potential_params)
    respond_to do |format|
      if @product_sales_potential.save
        format.html { redirect_to @product_sales_potential, notice: "Product sales potential was successfully created." }
        format.json { render :show, status: :created, location: @product_sales_potential }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product_sales_potential.errors, status: :unprocessable_entity }
      end
    end
  end
  def update
    respond_to do |format|
      if @product_sales_potential.update(product_sales_potential_params)
        format.html { redirect_to @product_sales_potential, notice: "Product sales potential was successfully updated." }
        format.json { render :show, status: :ok, location: @product_sales_potential }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product_sales_potential.errors, status: :unprocessable_entity }
      end
    end
  end
  def destroy
    @product_sales_potential.destroy
    respond_to do |format|
      format.html { redirect_to product_sales_potentials_url, notice: "Product sales potential was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_product_sales_potential
      @product_sales_potential = ProductSalesPotential.find(params[:id])
    end
    def product_sales_potential_params
      params.require(:product_sales_potential).permit(:id,:sales_potential)
    end
end
