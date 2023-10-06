class Vendor::OrdersController < ApplicationController
	before_action :if_not_vendor

	#中略
	def status_change
		order_material_id = params[:order_material_id]
		@order_material = OrderMaterial.find(order_material_id)
		@order_material.update(status:params[:status])
		if @order_material.status == 6
			@bg_color = "#d3d3d3"
			status = "商品発送完了"
		elsif @order_material.status == 4
			@bg_color = "#fffacd"
			status = "注文確認待ち"
		elsif @order_material.status == 7
			@bg_color = "silver"
			status = "キャンセル"
		else
			status = "注文確認完了"
			@bg_color = "white"
		end
		Slack::Notifier.new("https://hooks.slack.com/services/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", username: '監視君', icon_emoji: ':sunglasses:').ping("【注文ステータス変更】発注先：#{@order_material.material.vendor.company_name}　商品：#{@order_material.material.name}　ステータス：#{status}")
	end

	def index
		@vendor = Vendor.find_by(user_id:current_user.id)
		@order_materials = OrderMaterial.includes(:order,:material).order("delivery_date DESC").joins(:order,:material).where(un_order_flag:false,:orders => {fixed_flag:true},:materials => {vendor_id:@vendor.id}).page(params[:page]).per(20)
	end

	private
	def if_not_vendor
	  redirect_to root_path unless current_user.vendor_flag == true
	end
end
