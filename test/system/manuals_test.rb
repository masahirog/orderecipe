require "application_system_test_case"

class ManualsTest < ApplicationSystemTestCase
  setup do
    @manual = manuals(:one)
  end

  test "visiting the index" do
    visit manuals_url
    assert_selector "h1", text: "Manuals"
  end

  test "creating a Manual" do
    visit manuals_url
    click_on "New Manual"

    click_on "Create Manual"

    assert_text "Manual was successfully created"
    click_on "Back"
  end

  test "updating a Manual" do
    visit manuals_url
    click_on "Edit", match: :first

    click_on "Update Manual"

    assert_text "Manual was successfully updated"
    click_on "Back"
  end

  test "destroying a Manual" do
    visit manuals_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Manual was successfully destroyed"
  end
end
