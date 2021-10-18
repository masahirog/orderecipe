require "application_system_test_case"

class AnalysisProductsTest < ApplicationSystemTestCase
  setup do
    @analysis_product = analysis_products(:one)
  end

  test "visiting the index" do
    visit analysis_products_url
    assert_selector "h1", text: "Analysis Products"
  end

  test "creating a Analysis product" do
    visit analysis_products_url
    click_on "New Analysis Product"

    click_on "Create Analysis product"

    assert_text "Analysis product was successfully created"
    click_on "Back"
  end

  test "updating a Analysis product" do
    visit analysis_products_url
    click_on "Edit", match: :first

    click_on "Update Analysis product"

    assert_text "Analysis product was successfully updated"
    click_on "Back"
  end

  test "destroying a Analysis product" do
    visit analysis_products_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Analysis product was successfully destroyed"
  end
end
