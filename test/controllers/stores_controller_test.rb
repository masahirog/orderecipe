require 'test_helper'

class StoresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @store = stores(:one)
  end

  test "should get index" do
    get _stores_url
    assert_response :success
  end

  test "should get new" do
    get new__store_url
    assert_response :success
  end

  test "should create store" do
    assert_difference('Store.count') do
      post _stores_url, params: { store: {  } }
    end

    assert_redirected_to store_url(Store.last)
  end

  test "should show store" do
    get _store_url(@store)
    assert_response :success
  end

  test "should get edit" do
    get edit__store_url(@store)
    assert_response :success
  end

  test "should update store" do
    patch _store_url(@store), params: { store: {  } }
    assert_redirected_to store_url(@store)
  end

  test "should destroy store" do
    assert_difference('Store.count', -1) do
      delete _store_url(@store)
    end

    assert_redirected_to _stores_url
  end
end
