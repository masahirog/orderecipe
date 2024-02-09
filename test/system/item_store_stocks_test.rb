require "application_system_test_case"

class ItemStoreStocksTest < ApplicationSystemTestCase
  setup do
    @item_store_stock = item_store_stocks(:one)
  end

  test "visiting the index" do
    visit item_store_stocks_url
    assert_selector "h1", text: "Item Store Stocks"
  end

  test "creating a Item store stock" do
    visit item_store_stocks_url
    click_on "New Item Store Stock"

    click_on "Create Item store stock"

    assert_text "Item store stock was successfully created"
    click_on "Back"
  end

  test "updating a Item store stock" do
    visit item_store_stocks_url
    click_on "Edit", match: :first

    click_on "Update Item store stock"

    assert_text "Item store stock was successfully updated"
    click_on "Back"
  end

  test "destroying a Item store stock" do
    visit item_store_stocks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Item store stock was successfully destroyed"
  end
end
