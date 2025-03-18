require "test_helper"

class BusinessControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get business_new_url
    assert_response :success
  end

  test "should get create" do
    get business_create_url
    assert_response :success
  end

  test "should get show" do
    get business_show_url
    assert_response :success
  end

  test "should get index" do
    get business_index_url
    assert_response :success
  end
end
