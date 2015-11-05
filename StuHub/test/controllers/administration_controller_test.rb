require 'test_helper'

class AdministrationControllerTest < ActionController::TestCase
  test "should get main" do
    get :main
    assert_response :success
  end

end
