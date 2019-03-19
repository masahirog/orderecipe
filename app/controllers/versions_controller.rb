class VersionsController < ApplicationController
  def revert
    @version = PaperTrail::Version.find(params[:id])
    if @version.reify(has_many: true)
      @version.reify.save!
    else
      @version.item.destroy!
    end
    redirect_to root_path, notice: "#{@version.event} を取り消しました！"
  end
end
