require "application_system_test_case"

class CustomerOpinionsTest < ApplicationSystemTestCase
  setup do
    @customer_opinion = customer_opinions(:one)
  end

  test "visiting the index" do
    visit customer_opinions_url
    assert_selector "h1", text: "Customer Opinions"
  end

  test "creating a Customer opinion" do
    visit customer_opinions_url
    click_on "New Customer Opinion"

    click_on "Create Customer opinion"

    assert_text "Customer opinion was successfully created"
    click_on "Back"
  end

  test "updating a Customer opinion" do
    visit customer_opinions_url
    click_on "Edit", match: :first

    click_on "Update Customer opinion"

    assert_text "Customer opinion was successfully updated"
    click_on "Back"
  end

  test "destroying a Customer opinion" do
    visit customer_opinions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Customer opinion was successfully destroyed"
  end
end
