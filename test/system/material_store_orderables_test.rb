require "application_system_test_case"

class MaterialStoreOrderablesTest < ApplicationSystemTestCase
  setup do
    @material_store_orderable = material_store_orderables(:one)
  end

  test "visiting the index" do
    visit material_store_orderables_url
    assert_selector "h1", text: "Material Store Orderables"
  end

  test "creating a Material store orderable" do
    visit material_store_orderables_url
    click_on "New Material Store Orderable"

    click_on "Create Material store orderable"

    assert_text "Material store orderable was successfully created"
    click_on "Back"
  end

  test "updating a Material store orderable" do
    visit material_store_orderables_url
    click_on "Edit", match: :first

    click_on "Update Material store orderable"

    assert_text "Material store orderable was successfully updated"
    click_on "Back"
  end

  test "destroying a Material store orderable" do
    visit material_store_orderables_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Material store orderable was successfully destroyed"
  end
end
