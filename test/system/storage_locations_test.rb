require "application_system_test_case"

class StorageLocationsTest < ApplicationSystemTestCase
  setup do
    @storage_location = storage_locations(:one)
  end

  test "visiting the index" do
    visit storage_locations_url
    assert_selector "h1", text: "Storage Locations"
  end

  test "creating a Storage location" do
    visit storage_locations_url
    click_on "New Storage Location"

    click_on "Create Storage location"

    assert_text "Storage location was successfully created"
    click_on "Back"
  end

  test "updating a Storage location" do
    visit storage_locations_url
    click_on "Edit", match: :first

    click_on "Update Storage location"

    assert_text "Storage location was successfully updated"
    click_on "Back"
  end

  test "destroying a Storage location" do
    visit storage_locations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Storage location was successfully destroyed"
  end
end
