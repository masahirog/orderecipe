class Item < ApplicationRecord
	belongs_to :item_vendor
	belongs_to :item_variety
	has_many :item_order_items
	has_many :daily_items
	has_many :item_expiration_date
	has_many :item_store_stocks
	# enum category: {野菜:1,果物:2,物産:3,送料:4}
	enum unit: {袋:1,cs:2,本:3,kg:4,個:5,pc:6,口:7}, _prefix: true
	enum order_unit: {袋:1,cs:2,本:3,kg:4,個:5,pc:6,口:7}, _prefix: true
	enum status: {販売中:0,"販売中(入荷待ち)":1,販売終了:2,"終了(非表示)":3}
	def view_name_and_vendor
		self.name + "｜" +self.item_vendor.store_name
	end

	def self.search(params)
		if params[:category].present?
			item_variety_ids = ItemVariety.joins(:item_type).where(:item_types => {category:'物産品'}).ids
		end
		data = Item.order("id DESC")
		data = data.where(item_variety_id:item_variety_ids) if params[:category].present?
		data = data.where(item_variety_id:params[:item_variety_id]) if params[:item_variety_id].present?
		data = data.where(['items.name LIKE ?', "%#{params["name"]}%"]) if params["name"].present?
		data = data.where(item_vendor_id: params["item_vendor_id"]) if params["item_vendor_id"].present?
		data
	end
end
