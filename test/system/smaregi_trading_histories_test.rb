require "application_system_test_case"

class SmaregiTradingHistoriesTest < ApplicationSystemTestCase
  setup do
    @smaregi_trading_history = smaregi_trading_histories(:one)
  end

  test "visiting the index" do
    visit smaregi_trading_histories_url
    assert_selector "h1", text: "SmaregiTradingHistories"
  end

  test "creating a SmaregiTradingHistory" do
    visit smaregi_trading_histories_url
    click_on "New SmaregiTradingHistory"

    click_on "Create SmaregiTradingHistory"

    assert_text "SmaregiTradingHistory was successfully created"
    click_on "Back"
  end

  test "updating a SmaregiTradingHistory" do
    visit smaregi_trading_histories_url
    click_on "Edit", match: :first

    click_on "Update SmaregiTradingHistory"

    assert_text "SmaregiTradingHistory was successfully updated"
    click_on "Back"
  end

  test "destroying a SmaregiTradingHistory" do
    visit smaregi_trading_histories_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "SmaregiTradingHistory was successfully destroyed"
  end
end
