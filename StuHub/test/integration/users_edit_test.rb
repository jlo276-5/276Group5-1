require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:archer)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { password: "foo", password_confirmation: "bar" }
                                    assert_template 'users/edit'
  end

  test "successful edit with friendly forwarding" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { password: "", password_confirmation: "" }, new_email: "foo@bar.com", current_password: "password"
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal "foo@bar.com", @user.email_change_new
  end
end
