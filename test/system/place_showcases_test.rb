require "application_system_test_case"

class PlaceShowcasesTest < ApplicationSystemTestCase
  setup do
    @place_showcase = place_showcases(:one)
  end

  test "visiting the index" do
    visit place_showcases_url
    assert_selector "h1", text: "Place Showcases"
  end

  test "creating a Place showcase" do
    visit place_showcases_url
    click_on "New Place Showcase"

    click_on "Create Place showcase"

    assert_text "Place showcase was successfully created"
    click_on "Back"
  end

  test "updating a Place showcase" do
    visit place_showcases_url
    click_on "Edit", match: :first

    click_on "Update Place showcase"

    assert_text "Place showcase was successfully updated"
    click_on "Back"
  end

  test "destroying a Place showcase" do
    visit place_showcases_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Place showcase was successfully destroyed"
  end
end
