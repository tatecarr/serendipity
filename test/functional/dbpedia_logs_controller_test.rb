require 'test_helper'

class DbpediaLogsControllerTest < ActionController::TestCase
  setup do
    @dbpedia_log = dbpedia_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dbpedia_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dbpedia_log" do
    assert_difference('DbpediaLog.count') do
      post :create, dbpedia_log: { added_relationships: @dbpedia_log.added_relationships, info_type_id: @dbpedia_log.info_type_id, log_message: @dbpedia_log.log_message, source_id: @dbpedia_log.source_id, source_type: @dbpedia_log.source_type, status: @dbpedia_log.status }
    end

    assert_redirected_to dbpedia_log_path(assigns(:dbpedia_log))
  end

  test "should show dbpedia_log" do
    get :show, id: @dbpedia_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dbpedia_log
    assert_response :success
  end

  test "should update dbpedia_log" do
    put :update, id: @dbpedia_log, dbpedia_log: { added_relationships: @dbpedia_log.added_relationships, info_type_id: @dbpedia_log.info_type_id, log_message: @dbpedia_log.log_message, source_id: @dbpedia_log.source_id, source_type: @dbpedia_log.source_type, status: @dbpedia_log.status }
    assert_redirected_to dbpedia_log_path(assigns(:dbpedia_log))
  end

  test "should destroy dbpedia_log" do
    assert_difference('DbpediaLog.count', -1) do
      delete :destroy, id: @dbpedia_log
    end

    assert_redirected_to dbpedia_logs_path
  end
end
