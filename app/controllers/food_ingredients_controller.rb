class FoodIngredientsController < ApplicationController
  before_action :set_food_ingredient, only: %i[ show edit update destroy ]

  def reflect_seibun
    food_ingredient = FoodIngredient.find(params[:id]) 
    updates_arr = []
    menu_ids = []
    materials = food_ingredient.materials
    MenuMaterial.where(material_id:materials.ids).each do |mm|
      if mm.gram_quantity > 0
        if mm.material.food_ingredient_id.present?
          mm.calorie = (food_ingredient.calorie * mm.gram_quantity).round(2)
          mm.protein = (food_ingredient.protein * mm.gram_quantity).round(2)
          mm.lipid = (food_ingredient.lipid * mm.gram_quantity).round(2)
          mm.carbohydrate = (food_ingredient.carbohydrate * mm.gram_quantity).round(2)
          mm.dietary_fiber = (food_ingredient.dietary_fiber * mm.gram_quantity).round(2)
          mm.salt = (food_ingredient.salt * mm.gram_quantity).round(2)
          updates_arr << mm
          menu_ids << mm.menu_id
        end
      end
    end
    MenuMaterial.import updates_arr, on_duplicate_key_update:[:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt]
    menu_ids = menu_ids.uniq

    updates_arr = []
    Menu.where(id:menu_ids).each do |menu|
      menu.calorie = menu.menu_materials.sum(:calorie).round(2)
      menu.protein = menu.menu_materials.sum(:protein).round(2)
      menu.lipid = menu.menu_materials.sum(:lipid).round(2)
      menu.carbohydrate = menu.menu_materials.sum(:carbohydrate).round(2)
      menu.dietary_fiber = menu.menu_materials.sum(:dietary_fiber).round(2)
      menu.salt = menu.menu_materials.sum(:salt).round(2)
      updates_arr << menu
    end
    Menu.import updates_arr, on_duplicate_key_update:[:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt]

    products = Product.joins(:menus).where(:menus =>{id:menu_ids})
    updates_arr = []
    products.each do |product|
      product.calorie = product.menus.sum(:calorie).round(2)
      product.protein = product.menus.sum(:protein).round(2)
      product.lipid = product.menus.sum(:lipid).round(2)
      product.carbohydrate = product.menus.sum(:carbohydrate).round(2)
      product.dietary_fiber = product.menus.sum(:dietary_fiber).round(2)
      product.salt = product.menus.sum(:salt).round(2)
      updates_arr << product
    end
    Product.import updates_arr, on_duplicate_key_update:[:calorie,:protein,:lipid,:carbohydrate,:dietary_fiber,:salt]
    redirect_to food_ingredient,info:"#{food_ingredient.name}を使用するものを更新しました"
  end

  def index
    @food_ingredients = FoodIngredient.includes(:materials).all
    @food_ingredients = @food_ingredients.where("name LIKE ?", "%#{params[:name]}%").page(params[:page]).per(50)

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
