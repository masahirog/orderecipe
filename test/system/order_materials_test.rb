require "application_system_test_case"

class OrderMaterialsTest < ApplicationSystemTestCase
  setup do
    @order_material = order_materials(:one)
  end

  test "visiting the index" do
    visit order_materials_url
    assert_selector "h1", text: "Order Materials"
  end

  test "creating a Order material" do
    visit order_materials_url
    click_on "New Order Material"

    click_on "Create Order material"

    assert_text "Order material was successfully created"
    click_on "Back"
  end

  test "updating a Order material" do
    visit order_materials_url
    click_on "Edit", match: :first

    click_on "Update Order material"

    assert_text "Order material was successfully updated"
    click_on "Back"
  end

  test "destroying a Order material" do
    visit order_materials_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Order material was successfully destroyed"
  end
end
