require "application_system_test_case"

class WikiItemsTest < ApplicationSystemTestCase
  setup do
    @wiki_item = wiki_items(:one)
  end

  test "visiting the index" do
    visit wiki_items_url
    assert_selector "h1", text: "Wiki Items"
  end

  test "creating a Wiki item" do
    visit wiki_items_url
    click_on "New Wiki Item"

    click_on "Create Wiki item"

    assert_text "Wiki item was successfully created"
    click_on "Back"
  end

  test "updating a Wiki item" do
    visit wiki_items_url
    click_on "Edit", match: :first

    click_on "Update Wiki item"

    assert_text "Wiki item was successfully updated"
    click_on "Back"
  end

  test "destroying a Wiki item" do
    visit wiki_items_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Wiki item was successfully destroyed"
  end
end
