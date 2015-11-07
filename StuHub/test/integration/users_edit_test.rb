require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:archer)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name: "", email: "foo@invalid",
                                    password: "foo", password_confirmation: "bar" }
                                    assert_template 'users/edit'
  end

  test "successful edit with friendly forwarding" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name: "Foo Bar", email: "foo@bar.com",
                                    password: "", password_confirmation: "" }, current_password: "password"
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal "Foo Bar",  @user.name
    assert_equal "foo@bar.com", @user.email
  end
end
