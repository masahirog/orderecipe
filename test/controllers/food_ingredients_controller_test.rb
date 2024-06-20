require 'test_helper'

class FoodIngredientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @food_ingredient = food_ingredients(:one)
  end

  test "should get index" do
    get food_ingredients_url
    assert_response :success
  end

  test "should get new" do
    get new_food_ingredient_url
    assert_response :success
  end

  test "should create food_ingredient" do
    assert_difference('FoodIngredient.count') do
      post food_ingredients_url, params: { food_ingredient: {  } }
    end

    assert_redirected_to food_ingredient_url(FoodIngredient.last)
  end

  test "should show food_ingredient" do
    get food_ingredient_url(@food_ingredient)
    assert_response :success
  end

  test "should get edit" do
    get edit_food_ingredient_url(@food_ingredient)
    assert_response :success
  end

  test "should update food_ingredient" do
    patch food_ingredient_url(@food_ingredient), params: { food_ingredient: {  } }
    assert_redirected_to food_ingredient_url(@food_ingredient)
  end

  test "should destroy food_ingredient" do
    assert_difference('FoodIngredient.count', -1) do
      delete food_ingredient_url(@food_ingredient)
    end

    assert_redirected_to food_ingredients_url
  end
end
