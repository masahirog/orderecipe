require "application_system_test_case"

class ItemVarietiesTest < ApplicationSystemTestCase
  setup do
    @item_variety = item_varieties(:one)
  end

  test "visiting the index" do
    visit item_varieties_url
    assert_selector "h1", text: "Item Varieties"
  end

  test "creating a Item variety" do
    visit item_varieties_url
    click_on "New Item Variety"

    click_on "Create Item variety"

    assert_text "Item variety was successfully created"
    click_on "Back"
  end

  test "updating a Item variety" do
    visit item_varieties_url
    click_on "Edit", match: :first

    click_on "Update Item variety"

    assert_text "Item variety was successfully updated"
    click_on "Back"
  end

  test "destroying a Item variety" do
    visit item_varieties_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Item variety was successfully destroyed"
  end
end
