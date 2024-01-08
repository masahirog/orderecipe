require "application_system_test_case"

class DailyItemsTest < ApplicationSystemTestCase
  setup do
    @daily_item = daily_items(:one)
  end

  test "visiting the index" do
    visit daily_items_url
    assert_selector "h1", text: "Daily Items"
  end

  test "creating a Daily item" do
    visit daily_items_url
    click_on "New Daily Item"

    click_on "Create Daily item"

    assert_text "Daily item was successfully created"
    click_on "Back"
  end

  test "updating a Daily item" do
    visit daily_items_url
    click_on "Edit", match: :first

    click_on "Update Daily item"

    assert_text "Daily item was successfully updated"
    click_on "Back"
  end

  test "destroying a Daily item" do
    visit daily_items_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Daily item was successfully destroyed"
  end
end
