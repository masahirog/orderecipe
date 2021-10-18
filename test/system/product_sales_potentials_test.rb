require "application_system_test_case"

class ProductSalesPotentialsTest < ApplicationSystemTestCase
  setup do
    @product_sales_potential = product_sales_potentials(:one)
  end

  test "visiting the index" do
    visit product_sales_potentials_url
    assert_selector "h1", text: "Product Sales Potentials"
  end

  test "creating a Product sales potential" do
    visit product_sales_potentials_url
    click_on "New Product Sales Potential"

    click_on "Create Product sales potential"

    assert_text "Product sales potential was successfully created"
    click_on "Back"
  end

  test "updating a Product sales potential" do
    visit product_sales_potentials_url
    click_on "Edit", match: :first

    click_on "Update Product sales potential"

    assert_text "Product sales potential was successfully updated"
    click_on "Back"
  end

  test "destroying a Product sales potential" do
    visit product_sales_potentials_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Product sales potential was successfully destroyed"
  end
end
