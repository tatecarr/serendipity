require 'test_helper'

class TmpLatLongsControllerTest < ActionController::TestCase
  setup do
    @tmp_lat_long = tmp_lat_longs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tmp_lat_longs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tmp_lat_long" do
    assert_difference('TmpLatLong.count') do
      post :create, tmp_lat_long: { keyval: @tmp_lat_long.keyval, lat: @tmp_lat_long.lat, long: @tmp_lat_long.long, type: @tmp_lat_long.type }
    end

    assert_redirected_to tmp_lat_long_path(assigns(:tmp_lat_long))
  end

  test "should show tmp_lat_long" do
    get :show, id: @tmp_lat_long
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tmp_lat_long
    assert_response :success
  end

  test "should update tmp_lat_long" do
    put :update, id: @tmp_lat_long, tmp_lat_long: { keyval: @tmp_lat_long.keyval, lat: @tmp_lat_long.lat, long: @tmp_lat_long.long, type: @tmp_lat_long.type }
    assert_redirected_to tmp_lat_long_path(assigns(:tmp_lat_long))
  end

  test "should destroy tmp_lat_long" do
    assert_difference('TmpLatLong.count', -1) do
      delete :destroy, id: @tmp_lat_long
    end

    assert_redirected_to tmp_lat_longs_path
  end
end
