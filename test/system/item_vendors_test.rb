require "application_system_test_case"

class ItemVendorsTest < ApplicationSystemTestCase
  setup do
    @item_vendor = item_vendors(:one)
  end

  test "visiting the index" do
    visit item_vendors_url
    assert_selector "h1", text: "Item Vendors"
  end

  test "creating a Item vendor" do
    visit item_vendors_url
    click_on "New Item Vendor"

    click_on "Create Item vendor"

    assert_text "Item vendor was successfully created"
    click_on "Back"
  end

  test "updating a Item vendor" do
    visit item_vendors_url
    click_on "Edit", match: :first

    click_on "Update Item vendor"

    assert_text "Item vendor was successfully updated"
    click_on "Back"
  end

  test "destroying a Item vendor" do
    visit item_vendors_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Item vendor was successfully destroyed"
  end
end
