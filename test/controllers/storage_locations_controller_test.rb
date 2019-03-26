require 'test_helper'

class StorageLocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @storage_location = storage_locations(:one)
  end

  test "should get index" do
    get _storage_locations_url
    assert_response :success
  end

  test "should get new" do
    get new__storage_location_url
    assert_response :success
  end

  test "should create storage_location" do
    assert_difference('StorageLocation.count') do
      post _storage_locations_url, params: { storage_location: {  } }
    end

    assert_redirected_to storage_location_url(StorageLocation.last)
  end

  test "should show storage_location" do
    get _storage_location_url(@storage_location)
    assert_response :success
  end

  test "should get edit" do
    get edit__storage_location_url(@storage_location)
    assert_response :success
  end

  test "should update storage_location" do
    patch _storage_location_url(@storage_location), params: { storage_location: {  } }
    assert_redirected_to storage_location_url(@storage_location)
  end

  test "should destroy storage_location" do
    assert_difference('StorageLocation.count', -1) do
      delete _storage_location_url(@storage_location)
    end

    assert_redirected_to _storage_locations_url
  end
end
