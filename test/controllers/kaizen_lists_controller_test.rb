require 'test_helper'

class KaizenListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kaizen_list = kaizen_lists(:one)
  end

  test "should get index" do
    get kaizen_lists_url
    assert_response :success
  end

  test "should get new" do
    get new_kaizen_list_url
    assert_response :success
  end

  test "should create kaizen_list" do
    assert_difference('KaizenList.count') do
      post kaizen_lists_url, params: { kaizen_list: {  } }
    end

    assert_redirected_to kaizen_list_url(KaizenList.last)
  end

  test "should show kaizen_list" do
    get kaizen_list_url(@kaizen_list)
    assert_response :success
  end

  test "should get edit" do
    get edit_kaizen_list_url(@kaizen_list)
    assert_response :success
  end

  test "should update kaizen_list" do
    patch kaizen_list_url(@kaizen_list), params: { kaizen_list: {  } }
    assert_redirected_to kaizen_list_url(@kaizen_list)
  end

  test "should destroy kaizen_list" do
    assert_difference('KaizenList.count', -1) do
      delete kaizen_list_url(@kaizen_list)
    end

    assert_redirected_to kaizen_lists_url
  end
end
