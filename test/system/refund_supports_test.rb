require "application_system_test_case"

class RefundSupportsTest < ApplicationSystemTestCase
  setup do
    @refund_support = refund_supports(:one)
  end

  test "visiting the index" do
    visit refund_supports_url
    assert_selector "h1", text: "Refund Supports"
  end

  test "creating a Refund support" do
    visit refund_supports_url
    click_on "New Refund Support"

    click_on "Create Refund support"

    assert_text "Refund support was successfully created"
    click_on "Back"
  end

  test "updating a Refund support" do
    visit refund_supports_url
    click_on "Edit", match: :first

    click_on "Update Refund support"

    assert_text "Refund support was successfully updated"
    click_on "Back"
  end

  test "destroying a Refund support" do
    visit refund_supports_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Refund support was successfully destroyed"
  end
end
