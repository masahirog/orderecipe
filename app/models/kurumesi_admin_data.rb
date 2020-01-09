class KurumesiAdminData < ApplicationRecord
  def self.search(params)
    if params
      data = KurumesiAdminData.order('order_date DESC').all
      data = data.where(['store_name LIKE ?', "%#{params["store_name"]}%"]) if params["store_name"].present?
      data
    else
      KurumesiAdminData.order(:delivery_date).all
    end
  end
end
