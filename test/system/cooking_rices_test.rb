require "application_system_test_case"

class CookingRicesTest < ApplicationSystemTestCase
  setup do
    @cooking_rice = cooking_rices(:one)
  end

  test "visiting the index" do
    visit cooking_rices_url
    assert_selector "h1", text: "Cooking Rices"
  end

  test "creating a Cooking rice" do
    visit cooking_rices_url
    click_on "New Cooking Rice"

    click_on "Create Cooking rice"

    assert_text "Cooking rice was successfully created"
    click_on "Back"
  end

  test "updating a Cooking rice" do
    visit cooking_rices_url
    click_on "Edit", match: :first

    click_on "Update Cooking rice"

    assert_text "Cooking rice was successfully updated"
    click_on "Back"
  end

  test "destroying a Cooking rice" do
    visit cooking_rices_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Cooking rice was successfully destroyed"
  end
end
