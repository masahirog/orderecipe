class AdminController < ApplicationController
  before_action :if_not_admin
  # layout 'admin'

  #admniコントローラを継承しているページへの入り口ジャッジ
  def if_not_admin
    if current_user.admin?
    else
      if current_user.id == 49
        redirect_to '/shifts/check'
      elsif current_user.id == 59
        redirect_to '/outside_view'
        # redirect_to '/store/store_daily_menus'
      end
    end
  end
end
