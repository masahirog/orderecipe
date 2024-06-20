require "application_system_test_case"

class FoodIngredientsTest < ApplicationSystemTestCase
  setup do
    @food_ingredient = food_ingredients(:one)
  end

  test "visiting the index" do
    visit food_ingredients_url
    assert_selector "h1", text: "Food Ingredients"
  end

  test "creating a Food ingredient" do
    visit food_ingredients_url
    click_on "New Food Ingredient"

    click_on "Create Food ingredient"

    assert_text "Food ingredient was successfully created"
    click_on "Back"
  end

  test "updating a Food ingredient" do
    visit food_ingredients_url
    click_on "Edit", match: :first

    click_on "Update Food ingredient"

    assert_text "Food ingredient was successfully updated"
    click_on "Back"
  end

  test "destroying a Food ingredient" do
    visit food_ingredients_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Food ingredient was successfully destroyed"
  end
end
