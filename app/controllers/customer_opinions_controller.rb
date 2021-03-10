class CustomerOpinionsController < AdminController
  before_action :set_customer_opinion, only: [:show, :edit, :update, :destroy]

  def index
    @customer_opinion = CustomerOpinion.new
    @customer_opinion.date = Date.today
    @customer_opinions = CustomerOpinion.all.order(date:"DESC")
  end

  def show
  end

  def new
    @customer_opinion = CustomerOpinion.new
    @customer_opinion.date = Date.today
  end

  def edit
  end

  def create
    @customer_opinion = CustomerOpinion.new(customer_opinion_params)
    respond_to do |format|
      if @customer_opinion.save
        CustomerOpinion.post_shere(@customer_opinion)
        format.html { redirect_to customer_opinions_path, notice: '頂いた声をキッチンのみんなに届けるよ！！投稿ありがとう！' }
        format.json { render :show, status: :created, location: @customer_opinion }
      else
        format.html { render :new }
        format.json { render json: @customer_opinion.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @customer_opinion.update(customer_opinion_params)
        format.html { redirect_to @customer_opinion, notice: 'Customer opinion was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer_opinion }
      else
        format.html { render :edit }
        format.json { render json: @customer_opinion.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @customer_opinion.destroy
    respond_to do |format|
      format.html { redirect_to _customer_opinions_url, notice: 'Customer opinion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_customer_opinion
      @customer_opinion = CustomerOpinion.find(params[:id])
    end


    def customer_opinion_params
      params.require(:customer_opinion).permit(:id,:date,:content)
    end
end
