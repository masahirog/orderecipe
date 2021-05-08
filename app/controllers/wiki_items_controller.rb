class WikiItemsController < ApplicationController
  before_action :set_wiki_item, only: %i[ show edit update destroy ]

  def index
    @wiki_items = WikiItem.all
  end

  def show
    @wikis = Wiki.all
    @wiki = @wiki_item.wiki
  end

  def new
    @wiki_item = WikiItem.new
    @wiki_item.wiki_id = params[:wiki_id]

  end

  def edit
  end

  def create
    @wiki_item = WikiItem.new(wiki_item_params)
    @wiki = @wiki_item.wiki
    respond_to do |format|
      if @wiki_item.save
        format.html { redirect_to @wiki, notice: "Wiki item was successfully created." }
        format.json { render :show, status: :created, location: @wiki_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @wiki_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @wiki_item.update(wiki_item_params)
        format.html { redirect_to @wiki_item, notice: "Wiki item was successfully updated." }
        format.json { render :show, status: :ok, location: @wiki_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @wiki_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @wiki_item.destroy
    respond_to do |format|
      format.html { redirect_to wiki_items_url, notice: "Wiki item was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_wiki_item
      @wiki_item = WikiItem.find(params[:id])
    end


    def wiki_item_params
      params.require(:wiki_item).permit(:wiki_id,:title,:content,:row_order)
    end
end
