require "application_system_test_case"

class BuppanSchedulesTest < ApplicationSystemTestCase
  setup do
    @buppan_schedule = buppan_schedules(:one)
  end

  test "visiting the index" do
    visit buppan_schedules_url
    assert_selector "h1", text: "Buppan Schedules"
  end

  test "creating a Buppan schedule" do
    visit buppan_schedules_url
    click_on "New Buppan Schedule"

    click_on "Create Buppan schedule"

    assert_text "Buppan schedule was successfully created"
    click_on "Back"
  end

  test "updating a Buppan schedule" do
    visit buppan_schedules_url
    click_on "Edit", match: :first

    click_on "Update Buppan schedule"

    assert_text "Buppan schedule was successfully updated"
    click_on "Back"
  end

  test "destroying a Buppan schedule" do
    visit buppan_schedules_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Buppan schedule was successfully destroyed"
  end
end
