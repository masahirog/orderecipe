class FoodAdditivesController < AdminController
  def create
    @food_additive = FoodAdditive.create(food_additive_params)
    respond_to do |format|
      if @food_additive.save
        format.html { redirect_to @food_additive, notice: 'successfully created.' }
        format.json { render :show, status: :created, location: @food_additive }
        format.js { @status = "success",@food_additive}
      else
        format.html { render :new }
        format.json { render json: @food_additive.errors, status: :unprocessable_entity }
        format.js { @status = "fail" }
      end
    end
  end
  private
  def food_additive_params
    params.require(:food_additive).permit(:name)
  end
end
