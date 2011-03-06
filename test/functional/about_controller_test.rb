require 'test_helper'

class AboutControllerTest < ActionController::TestCase
  test "should get people" do
    get :people
    assert_response :success
  end

  test "should get project" do
    get :project
    assert_response :success
  end

  test "should get process" do
    get :process
    assert_response :success
  end

end
