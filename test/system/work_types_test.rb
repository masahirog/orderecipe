require "application_system_test_case"

class WorkTypesTest < ApplicationSystemTestCase
  setup do
    @work_type = work_types(:one)
  end

  test "visiting the index" do
    visit work_types_url
    assert_selector "h1", text: "Work Types"
  end

  test "creating a Work type" do
    visit work_types_url
    click_on "New Work Type"

    click_on "Create Work type"

    assert_text "Work type was successfully created"
    click_on "Back"
  end

  test "updating a Work type" do
    visit work_types_url
    click_on "Edit", match: :first

    click_on "Update Work type"

    assert_text "Work type was successfully updated"
    click_on "Back"
  end

  test "destroying a Work type" do
    visit work_types_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Work type was successfully destroyed"
  end
end
