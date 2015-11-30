require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @institution = institutions(:institution)
  end

  test "invalid registration" do
    get register_path
    assert_no_difference 'User.count' do
      post users_path, user: {email: "",
                              password: "foo", password_confirmation: "bar"}
    end
    assert_template 'users/new'
  end

  test "valid registration with activation" do
    get register_path
    assert_difference 'User.count', 1 do
      post users_path, user: {email: "tester@example.com",
                              password: "test123", password_confirmation: "test123", tos_agree: true}
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: "tester@example.com")
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    assert_redirected_to user
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

end
