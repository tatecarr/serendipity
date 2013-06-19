require 'test_helper'

class DbpediaInfosControllerTest < ActionController::TestCase
  setup do
    @dbpedia_info = dbpedia_infos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dbpedia_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dbpedia_info" do
    assert_difference('DbpediaInfo.count') do
      post :create, dbpedia_info: { entity_type_id: @dbpedia_info.entity_type_id, info_type_desc: @dbpedia_info.info_type_desc }
    end

    assert_redirected_to dbpedia_info_path(assigns(:dbpedia_info))
  end

  test "should show dbpedia_info" do
    get :show, id: @dbpedia_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dbpedia_info
    assert_response :success
  end

  test "should update dbpedia_info" do
    put :update, id: @dbpedia_info, dbpedia_info: { entity_type_id: @dbpedia_info.entity_type_id, info_type_desc: @dbpedia_info.info_type_desc }
    assert_redirected_to dbpedia_info_path(assigns(:dbpedia_info))
  end

  test "should destroy dbpedia_info" do
    assert_difference('DbpediaInfo.count', -1) do
      delete :destroy, id: @dbpedia_info
    end

    assert_redirected_to dbpedia_infos_path
  end
end
