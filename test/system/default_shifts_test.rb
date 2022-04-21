require "application_system_test_case"

class DefaultShiftsTest < ApplicationSystemTestCase
  setup do
    @default_shift = default_shifts(:one)
  end

  test "visiting the index" do
    visit default_shifts_url
    assert_selector "h1", text: "Default Shifts"
  end

  test "creating a Default shift" do
    visit default_shifts_url
    click_on "New Default Shift"

    click_on "Create Default shift"

    assert_text "Default shift was successfully created"
    click_on "Back"
  end

  test "updating a Default shift" do
    visit default_shifts_url
    click_on "Edit", match: :first

    click_on "Update Default shift"

    assert_text "Default shift was successfully updated"
    click_on "Back"
  end

  test "destroying a Default shift" do
    visit default_shifts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Default shift was successfully destroyed"
  end
end
