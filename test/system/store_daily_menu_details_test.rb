require "application_system_test_case"

class StoreDailyMenuDetailsTest < ApplicationSystemTestCase
  setup do
    @store_daily_menu_detail = store_daily_menu_details(:one)
  end

  test "visiting the index" do
    visit store_daily_menu_details_url
    assert_selector "h1", text: "Store Daily Menu Details"
  end

  test "creating a Store daily menu detail" do
    visit store_daily_menu_details_url
    click_on "New Store Daily Menu Detail"

    click_on "Create Store daily menu detail"

    assert_text "Store daily menu detail was successfully created"
    click_on "Back"
  end

  test "updating a Store daily menu detail" do
    visit store_daily_menu_details_url
    click_on "Edit", match: :first

    click_on "Update Store daily menu detail"

    assert_text "Store daily menu detail was successfully updated"
    click_on "Back"
  end

  test "destroying a Store daily menu detail" do
    visit store_daily_menu_details_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Store daily menu detail was successfully destroyed"
  end
end
