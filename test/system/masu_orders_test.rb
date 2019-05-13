require "application_system_test_case"

class MasuOrdersTest < ApplicationSystemTestCase
  setup do
    @masu_order = masu_orders(:one)
  end

  test "visiting the index" do
    visit masu_orders_url
    assert_selector "h1", text: "Masu Orders"
  end

  test "creating a Masu order" do
    visit masu_orders_url
    click_on "New Masu Order"

    click_on "Create Masu order"

    assert_text "Masu order was successfully created"
    click_on "Back"
  end

  test "updating a Masu order" do
    visit masu_orders_url
    click_on "Edit", match: :first

    click_on "Update Masu order"

    assert_text "Masu order was successfully updated"
    click_on "Back"
  end

  test "destroying a Masu order" do
    visit masu_orders_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Masu order was successfully destroyed"
  end
end
