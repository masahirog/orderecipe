require "application_system_test_case"

class TastingsTest < ApplicationSystemTestCase
  setup do
    @tasting = tastings(:one)
  end

  test "visiting the index" do
    visit tastings_url
    assert_selector "h1", text: "Tastings"
  end

  test "creating a Tasting" do
    visit tastings_url
    click_on "New Tasting"

    click_on "Create Tasting"

    assert_text "Tasting was successfully created"
    click_on "Back"
  end

  test "updating a Tasting" do
    visit tastings_url
    click_on "Edit", match: :first

    click_on "Update Tasting"

    assert_text "Tasting was successfully updated"
    click_on "Back"
  end

  test "destroying a Tasting" do
    visit tastings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Tasting was successfully destroyed"
  end
end
