require 'test_helper'

class SmaregiTradingHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @smaregi_trading_history = smaregi_trading_histories(:one)
  end

  test "should get index" do
    get smaregi_trading_histories_url
    assert_response :success
  end

  test "should get new" do
    get new_smaregi_trading_history_url
    assert_response :success
  end

  test "should create smaregi_trading_history" do
    assert_difference('SmaregiTradingHistory.count') do
      post smaregi_trading_histories_url, params: { smaregi_trading_history: {  } }
    end

    assert_redirected_to smaregi_trading_history_url(SmaregiTradingHistory.last)
  end

  test "should show smaregi_trading_history" do
    get smaregi_trading_history_url(@smaregi_trading_history)
    assert_response :success
  end

  test "should get edit" do
    get edit_smaregi_trading_history_url(@smaregi_trading_history)
    assert_response :success
  end

  test "should update smaregi_trading_history" do
    patch smaregi_trading_history_url(@smaregi_trading_history), params: { smaregi_trading_history: {  } }
    assert_redirected_to smaregi_trading_history_url(@smaregi_trading_history)
  end

  test "should destroy smaregi_trading_history" do
    assert_difference('SmaregiTradingHistory.count', -1) do
      delete smaregi_trading_history_url(@smaregi_trading_history)
    end

    assert_redirected_to smaregi_trading_histories_url
  end
end
