require "application_system_test_case"

class ItemOrdersTest < ApplicationSystemTestCase
  setup do
    @item_order = item_orders(:one)
  end

  test "visiting the index" do
    visit item_orders_url
    assert_selector "h1", text: "Item Orders"
  end

  test "creating a Item order" do
    visit item_orders_url
    click_on "New Item Order"

    click_on "Create Item order"

    assert_text "Item order was successfully created"
    click_on "Back"
  end

  test "updating a Item order" do
    visit item_orders_url
    click_on "Edit", match: :first

    click_on "Update Item order"

    assert_text "Item order was successfully updated"
    click_on "Back"
  end

  test "destroying a Item order" do
    visit item_orders_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Item order was successfully destroyed"
  end
end
