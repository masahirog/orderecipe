require "application_system_test_case"

class CommonProductPartsTest < ApplicationSystemTestCase
  setup do
    @common_product_part = common_product_parts(:one)
  end

  test "visiting the index" do
    visit common_product_parts_url
    assert_selector "h1", text: "Common Product Parts"
  end

  test "creating a Common product part" do
    visit common_product_parts_url
    click_on "New Common Product Part"

    click_on "Create Common product part"

    assert_text "Common product part was successfully created"
    click_on "Back"
  end

  test "updating a Common product part" do
    visit common_product_parts_url
    click_on "Edit", match: :first

    click_on "Update Common product part"

    assert_text "Common product part was successfully updated"
    click_on "Back"
  end

  test "destroying a Common product part" do
    visit common_product_parts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Common product part was successfully destroyed"
  end
end
