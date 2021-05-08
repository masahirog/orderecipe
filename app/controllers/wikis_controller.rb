class WikisController < ApplicationController
  before_action :set_wiki, only: %i[ show edit update destroy ]

  def index
    @wikis = Wiki.all
  end

  def show
    @wikis = Wiki.all
  end

  def new
    @wiki = Wiki.new
  end

  def edit
  end

  def create
    @wiki = Wiki.new(wiki_params)

    respond_to do |format|
      if @wiki.save
        format.html { redirect_to @wiki, notice: "Wiki was successfully created." }
        format.json { render :show, status: :created, location: @wiki }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @wiki.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @wiki.update(wiki_params)
        format.html { redirect_to @wiki, notice: "Wiki was successfully updated." }
        format.json { render :show, status: :ok, location: @wiki }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @wiki.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @wiki.destroy
    respond_to do |format|
      format.html { redirect_to wikis_url, notice: "Wiki was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_wiki
      @wiki = Wiki.find(params[:id])
    end

    def wiki_params
      params.require(:wiki).permit(:name,:summary,:row_order)
    end
end
