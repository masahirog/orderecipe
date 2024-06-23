require "application_system_test_case"

class TemporaryProductMenusTest < ApplicationSystemTestCase
  setup do
    @temporary_product_menu = temporary_product_menus(:one)
  end

  test "visiting the index" do
    visit temporary_product_menus_url
    assert_selector "h1", text: "Temporary Product Menus"
  end

  test "creating a Temporary product menu" do
    visit temporary_product_menus_url
    click_on "New Temporary Product Menu"

    click_on "Create Temporary product menu"

    assert_text "Temporary product menu was successfully created"
    click_on "Back"
  end

  test "updating a Temporary product menu" do
    visit temporary_product_menus_url
    click_on "Edit", match: :first

    click_on "Update Temporary product menu"

    assert_text "Temporary product menu was successfully updated"
    click_on "Back"
  end

  test "destroying a Temporary product menu" do
    visit temporary_product_menus_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Temporary product menu was successfully destroyed"
  end
end
