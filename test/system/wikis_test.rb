require "application_system_test_case"

class WikisTest < ApplicationSystemTestCase
  setup do
    @wiki = wikis(:one)
  end

  test "visiting the index" do
    visit wikis_url
    assert_selector "h1", text: "Wikis"
  end

  test "creating a Wiki" do
    visit wikis_url
    click_on "New Wiki"

    click_on "Create Wiki"

    assert_text "Wiki was successfully created"
    click_on "Back"
  end

  test "updating a Wiki" do
    visit wikis_url
    click_on "Edit", match: :first

    click_on "Update Wiki"

    assert_text "Wiki was successfully updated"
    click_on "Back"
  end

  test "destroying a Wiki" do
    visit wikis_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wiki was successfully destroyed"
  end
end
