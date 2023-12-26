require 'test_helper'

class ToStoreMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @to_store_message = to_store_messages(:one)
  end

  test "should get index" do
    get to_store_messages_url
    assert_response :success
  end

  test "should get new" do
    get new_to_store_message_url
    assert_response :success
  end

  test "should create to_store_message" do
    assert_difference('ToStoreMessage.count') do
      post to_store_messages_url, params: { to_store_message: {  } }
    end

    assert_redirected_to to_store_message_url(ToStoreMessage.last)
  end

  test "should show to_store_message" do
    get to_store_message_url(@to_store_message)
    assert_response :success
  end

  test "should get edit" do
    get edit_to_store_message_url(@to_store_message)
    assert_response :success
  end

  test "should update to_store_message" do
    patch to_store_message_url(@to_store_message), params: { to_store_message: {  } }
    assert_redirected_to to_store_message_url(@to_store_message)
  end

  test "should destroy to_store_message" do
    assert_difference('ToStoreMessage.count', -1) do
      delete to_store_message_url(@to_store_message)
    end

    assert_redirected_to to_store_messages_url
  end
end
