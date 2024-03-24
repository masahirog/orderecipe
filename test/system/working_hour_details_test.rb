require "application_system_test_case"

class WorkingHourDetailsTest < ApplicationSystemTestCase
  setup do
    @working_hour_detail = working_hour_details(:one)
  end

  test "visiting the index" do
    visit working_hour_details_url
    assert_selector "h1", text: "Working Hour Details"
  end

  test "creating a Working hour detail" do
    visit working_hour_details_url
    click_on "New Working Hour Detail"

    click_on "Create Working hour detail"

    assert_text "Working hour detail was successfully created"
    click_on "Back"
  end

  test "updating a Working hour detail" do
    visit working_hour_details_url
    click_on "Edit", match: :first

    click_on "Update Working hour detail"

    assert_text "Working hour detail was successfully updated"
    click_on "Back"
  end

  test "destroying a Working hour detail" do
    visit working_hour_details_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Working hour detail was successfully destroyed"
  end
end
