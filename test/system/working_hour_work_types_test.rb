require "application_system_test_case"

class WorkingHourWorkTypesTest < ApplicationSystemTestCase
  setup do
    @working_hour_work_type = working_hour_work_types(:one)
  end

  test "visiting the index" do
    visit working_hour_work_types_url
    assert_selector "h1", text: "Working Hour Work Types"
  end

  test "creating a Working hour work type" do
    visit working_hour_work_types_url
    click_on "New Working Hour Work Type"

    click_on "Create Working hour work type"

    assert_text "Working hour work type was successfully created"
    click_on "Back"
  end

  test "updating a Working hour work type" do
    visit working_hour_work_types_url
    click_on "Edit", match: :first

    click_on "Update Working hour work type"

    assert_text "Working hour work type was successfully updated"
    click_on "Back"
  end

  test "destroying a Working hour work type" do
    visit working_hour_work_types_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Working hour work type was successfully destroyed"
  end
end
