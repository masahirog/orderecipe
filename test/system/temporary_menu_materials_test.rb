require "application_system_test_case"

class TemporaryMenuMaterialsTest < ApplicationSystemTestCase
  setup do
    @temporary_menu_material = temporary_menu_materials(:one)
  end

  test "visiting the index" do
    visit temporary_menu_materials_url
    assert_selector "h1", text: "Temporary Menu Materials"
  end

  test "creating a Temporary menu material" do
    visit temporary_menu_materials_url
    click_on "New Temporary Menu Material"

    click_on "Create Temporary menu material"

    assert_text "Temporary menu material was successfully created"
    click_on "Back"
  end

  test "updating a Temporary menu material" do
    visit temporary_menu_materials_url
    click_on "Edit", match: :first

    click_on "Update Temporary menu material"

    assert_text "Temporary menu material was successfully updated"
    click_on "Back"
  end

  test "destroying a Temporary menu material" do
    visit temporary_menu_materials_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Temporary menu material was successfully destroyed"
  end
end
