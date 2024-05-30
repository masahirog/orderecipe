require "application_system_test_case"

class PreOrdersTest < ApplicationSystemTestCase
  setup do
    @pre_order = pre_orders(:one)
  end

  test "visiting the index" do
    visit pre_orders_url
    assert_selector "h1", text: "Pre Orders"
  end

  test "creating a Pre order" do
    visit pre_orders_url
    click_on "New Pre Order"

    click_on "Create Pre order"

    assert_text "Pre order was successfully created"
    click_on "Back"
  end

  test "updating a Pre order" do
    visit pre_orders_url
    click_on "Edit", match: :first

    click_on "Update Pre order"

    assert_text "Pre order was successfully updated"
    click_on "Back"
  end

  test "destroying a Pre order" do
    visit pre_orders_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Pre order was successfully destroyed"
  end
end
