require "application_system_test_case"

class StoreDailyMenuDetailHistoriesTest < ApplicationSystemTestCase
  setup do
    @store_daily_menu_detail_history = store_daily_menu_detail_histories(:one)
  end

  test "visiting the index" do
    visit store_daily_menu_detail_histories_url
    assert_selector "h1", text: "Store Daily Menu Detail Histories"
  end

  test "creating a Store daily menu detail history" do
    visit store_daily_menu_detail_histories_url
    click_on "New Store Daily Menu Detail History"

    click_on "Create Store daily menu detail history"

    assert_text "Store daily menu detail history was successfully created"
    click_on "Back"
  end

  test "updating a Store daily menu detail history" do
    visit store_daily_menu_detail_histories_url
    click_on "Edit", match: :first

    click_on "Update Store daily menu detail history"

    assert_text "Store daily menu detail history was successfully updated"
    click_on "Back"
  end

  test "destroying a Store daily menu detail history" do
    visit store_daily_menu_detail_histories_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Store daily menu detail history was successfully destroyed"
  end
end
