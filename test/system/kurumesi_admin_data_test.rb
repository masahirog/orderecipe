require "application_system_test_case"

class KurumesiAdminDataTest < ApplicationSystemTestCase
  setup do
    @kurumesi_admin_data = kurumesi_admin_data(:one)
  end

  test "visiting the index" do
    visit kurumesi_admin_data_url
    assert_selector "h1", text: "Kurumesi Admin Data"
  end

  test "creating a Kurumesi admin datum" do
    visit kurumesi_admin_data_url
    click_on "New Kurumesi Admin Datum"

    click_on "Create Kurumesi admin datum"

    assert_text "Kurumesi admin datum was successfully created"
    click_on "Back"
  end

  test "updating a Kurumesi admin datum" do
    visit kurumesi_admin_data_url
    click_on "Edit", match: :first

    click_on "Update Kurumesi admin datum"

    assert_text "Kurumesi admin datum was successfully updated"
    click_on "Back"
  end

  test "destroying a Kurumesi admin datum" do
    visit kurumesi_admin_data_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Kurumesi admin datum was successfully destroyed"
  end
end
