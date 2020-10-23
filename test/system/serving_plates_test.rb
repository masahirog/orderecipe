require "application_system_test_case"

class ServingPlatesTest < ApplicationSystemTestCase
  setup do
    @serving_plate = serving_plates(:one)
  end

  test "visiting the index" do
    visit serving_plates_url
    assert_selector "h1", text: "Serving Plates"
  end

  test "creating a Serving plate" do
    visit serving_plates_url
    click_on "New Serving Plate"

    click_on "Create Serving plate"

    assert_text "Serving plate was successfully created"
    click_on "Back"
  end

  test "updating a Serving plate" do
    visit serving_plates_url
    click_on "Edit", match: :first

    click_on "Update Serving plate"

    assert_text "Serving plate was successfully updated"
    click_on "Back"
  end

  test "destroying a Serving plate" do
    visit serving_plates_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Serving plate was successfully destroyed"
  end
end
