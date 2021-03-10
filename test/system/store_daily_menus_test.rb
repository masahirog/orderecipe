require "application_system_test_case"

class StoreDailyMenusTest < ApplicationSystemTestCase
  setup do
    @store_daily_menu = store_daily_menus(:one)
  end

  test "visiting the index" do
    visit store_daily_menus_url
    assert_selector "h1", text: "Store Daily Menus"
  end

  test "creating a Store daily menu" do
    visit store_daily_menus_url
    click_on "New Store Daily Menu"

    click_on "Create Store daily menu"

    assert_text "Store daily menu was successfully created"
    click_on "Back"
  end

  test "updating a Store daily menu" do
    visit store_daily_menus_url
    click_on "Edit", match: :first

    click_on "Update Store daily menu"

    assert_text "Store daily menu was successfully updated"
    click_on "Back"
  end

  test "destroying a Store daily menu" do
    visit store_daily_menus_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Store daily menu was successfully destroyed"
  end
end
