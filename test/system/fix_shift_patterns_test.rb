require "application_system_test_case"

class FixShiftPatternsTest < ApplicationSystemTestCase
  setup do
    @fix_shift_pattern = fix_shift_patterns(:one)
  end

  test "visiting the index" do
    visit fix_shift_patterns_url
    assert_selector "h1", text: "Fix Shift Patterns"
  end

  test "creating a Fix shift pattern" do
    visit fix_shift_patterns_url
    click_on "New Fix Shift Pattern"

    click_on "Create Fix shift pattern"

    assert_text "Fix shift pattern was successfully created"
    click_on "Back"
  end

  test "updating a Fix shift pattern" do
    visit fix_shift_patterns_url
    click_on "Edit", match: :first

    click_on "Update Fix shift pattern"

    assert_text "Fix shift pattern was successfully updated"
    click_on "Back"
  end

  test "destroying a Fix shift pattern" do
    visit fix_shift_patterns_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Fix shift pattern was successfully destroyed"
  end
end
