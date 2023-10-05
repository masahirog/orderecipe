class Vendor::OrdersController < ApplicationController
	before_action :if_not_vendor

	#中略
	def status_change
		order_material_id = params[:order_material_id]
		@order_material = OrderMaterial.find(order_material_id)
		@order_material.update(status:params[:status])
		if @order_material.status == 6
			@bg_color = "#d3d3d3"
		elsif @order_material.status == 4
			@bg_color = "#fffacd"
		else
			@bg_color = "white"
		end
	end

	def index
		@vendor = Vendor.find_by(user_id:current_user.id)
		@order_materials = OrderMaterial.includes(:order,:material).order("delivery_date DESC").joins(:material).where(un_order_flag:false,:materials => {vendor_id:@vendor.id}).page(params[:page]).per(20)
	end

	private
	def if_not_vendor
	  redirect_to root_path unless current_user.vendor_flag == true
	end
end
