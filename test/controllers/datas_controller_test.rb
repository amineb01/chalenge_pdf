require 'test_helper'

class DatasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get datas_index_url
    assert_response :success
  end

  test "should get new" do
    get datas_new_url
    assert_response :success
  end

  test "should get create" do
    get datas_create_url
    assert_response :success
  end

  test "should get destroy" do
    get datas_destroy_url
    assert_response :success
  end

end
