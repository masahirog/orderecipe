require "application_system_test_case"

class DailyMenusTest < ApplicationSystemTestCase
  setup do
    @daily_menu = daily_menus(:one)
  end

  test "visiting the index" do
    visit daily_menus_url
    assert_selector "h1", text: "Daily Menus"
  end

  test "creating a Daily menu" do
    visit daily_menus_url
    click_on "New Daily Menu"

    click_on "Create Daily menu"

    assert_text "Daily menu was successfully created"
    click_on "Back"
  end

  test "updating a Daily menu" do
    visit daily_menus_url
    click_on "Edit", match: :first

    click_on "Update Daily menu"

    assert_text "Daily menu was successfully updated"
    click_on "Back"
  end

  test "destroying a Daily menu" do
    visit daily_menus_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Daily menu was successfully destroyed"
  end
end
