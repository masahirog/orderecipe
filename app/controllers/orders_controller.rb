class OrdersController < ApplicationController
    def material_info
      @material = Material.find(params[:id])
      respond_to do |format|
        format.html
        format.json
      end
    end

  def confirm
    @order = Order.new(order_create_update) # <=POSTされたパラメータを取得
  end

  def index
    @products = Product.all
    @orders = Order.all
  end
  def new
    @order = Order.new
    @order.order_materials.build
    @hash = Material.calculate_products_materials(params)
  end

  def create
    @order = Order.create(order_create_update)
     if @order.save
       redirect_to "/orders/#{@order.id}"
     else
       render 'new'
     end
  end

  def show
    @order = Order.find(params[:id])
    @order_materials = @order.order_materials
    @materials = @order.materials

  end

  def order_print
    @order = Order.find(params[:id])
    render :order_print, layout: false #このページでlayoutを適用させない
  end

  private

  def order_create_update
    params.require(:order).permit(:delivery_date,order_materials_attributes: [:id, :order_quantity, :order_id, :material_id, :_destroy])
  end

end
