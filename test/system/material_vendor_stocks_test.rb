require "application_system_test_case"

class MaterialVendorStocksTest < ApplicationSystemTestCase
  setup do
    @material_vendor_stock = material_vendor_stocks(:one)
  end

  test "visiting the index" do
    visit material_vendor_stocks_url
    assert_selector "h1", text: "Material Vendor Stocks"
  end

  test "creating a Material vendor stock" do
    visit material_vendor_stocks_url
    click_on "New Material Vendor Stock"

    click_on "Create Material vendor stock"

    assert_text "Material vendor stock was successfully created"
    click_on "Back"
  end

  test "updating a Material vendor stock" do
    visit material_vendor_stocks_url
    click_on "Edit", match: :first

    click_on "Update Material vendor stock"

    assert_text "Material vendor stock was successfully updated"
    click_on "Back"
  end

  test "destroying a Material vendor stock" do
    visit material_vendor_stocks_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Material vendor stock was successfully destroyed"
  end
end
