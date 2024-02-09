require "application_system_test_case"

class ItemExpirationDatesTest < ApplicationSystemTestCase
  setup do
    @item_expiration_date = item_expiration_dates(:one)
  end

  test "visiting the index" do
    visit item_expiration_dates_url
    assert_selector "h1", text: "Item Expiration Dates"
  end

  test "creating a Item expiration date" do
    visit item_expiration_dates_url
    click_on "New Item Expiration Date"

    click_on "Create Item expiration date"

    assert_text "Item expiration date was successfully created"
    click_on "Back"
  end

  test "updating a Item expiration date" do
    visit item_expiration_dates_url
    click_on "Edit", match: :first

    click_on "Update Item expiration date"

    assert_text "Item expiration date was successfully updated"
    click_on "Back"
  end

  test "destroying a Item expiration date" do
    visit item_expiration_dates_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Item expiration date was successfully destroyed"
  end
end
