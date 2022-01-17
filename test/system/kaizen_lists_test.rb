require "application_system_test_case"

class KaizenListsTest < ApplicationSystemTestCase
  setup do
    @kaizen_list = kaizen_lists(:one)
  end

  test "visiting the index" do
    visit kaizen_lists_url
    assert_selector "h1", text: "Kaizen Lists"
  end

  test "creating a Kaizen list" do
    visit kaizen_lists_url
    click_on "New Kaizen List"

    click_on "Create Kaizen list"

    assert_text "Kaizen list was successfully created"
    click_on "Back"
  end

  test "updating a Kaizen list" do
    visit kaizen_lists_url
    click_on "Edit", match: :first

    click_on "Update Kaizen list"

    assert_text "Kaizen list was successfully updated"
    click_on "Back"
  end

  test "destroying a Kaizen list" do
    visit kaizen_lists_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Kaizen list was successfully destroyed"
  end
end
