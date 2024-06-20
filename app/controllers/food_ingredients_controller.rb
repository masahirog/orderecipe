class FoodIngredientsController < ApplicationController
  before_action :set_food_ingredient, only: %i[ show edit update destroy ]

  def index
    @food_ingredients = FoodIngredient.includes(:materials).all.page(params[:page]).per(50)

  end

  def show
  end

  def new
    @food_ingredient = FoodIngredient.new
  end

  def edit
  end

  def create
    @food_ingredient = FoodIngredient.new(food_ingredient_params)

    respond_to do |format|
      if @food_ingredient.save
        format.html { redirect_to food_ingredient_url(@food_ingredient), notice: "Food ingredient was successfully created." }
        format.json { render :show, status: :created, location: @food_ingredient }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @food_ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @food_ingredient.update(food_ingredient_params)
        format.html { redirect_to food_ingredient_url(@food_ingredient), notice: "Food ingredient was successfully updated." }
        format.json { render :show, status: :ok, location: @food_ingredient }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @food_ingredient.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @food_ingredient.destroy

    respond_to do |format|
      format.html { redirect_to food_ingredients_url, notice: "Food ingredient was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_food_ingredient
      @food_ingredient = FoodIngredient.find(params[:id])
    end

    def food_ingredient_params
      params.require(:food_ingredient).permit(:food_group,:food_number,:index_number,:name,:complement,:calorie,:protein,:lipid,:carbohydrate,
        :dietary_fiber,:potassium,:calcium,:vitamin_b1,:vitamin_b2,:vitamin_c,:salt,:memo,:magnesium,:iron,:zinc,:copper,:folic_acid,:vitamin_d)
    end
end
