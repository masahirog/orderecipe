require "application_system_test_case"

class WeeklyReportsTest < ApplicationSystemTestCase
  setup do
    @weekly_report = weekly_reports(:one)
  end

  test "visiting the index" do
    visit weekly_reports_url
    assert_selector "h1", text: "Weekly Reports"
  end

  test "creating a Weekly report" do
    visit weekly_reports_url
    click_on "New Weekly Report"

    click_on "Create Weekly report"

    assert_text "Weekly report was successfully created"
    click_on "Back"
  end

  test "updating a Weekly report" do
    visit weekly_reports_url
    click_on "Edit", match: :first

    click_on "Update Weekly report"

    assert_text "Weekly report was successfully updated"
    click_on "Back"
  end

  test "destroying a Weekly report" do
    visit weekly_reports_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Weekly report was successfully destroyed"
  end
end
