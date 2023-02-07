class Crew::StoresController < ApplicationController
	def show
    @store = Store.find(params[:id])
  end
  def index
  	@stores = Store.where(group_id:29)
  end
end
