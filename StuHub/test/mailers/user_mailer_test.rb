require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  def setup
    @user = users(:michael)
  end

  test "check account activation email" do
    @user.activation_token = User.new_token
    mail = UserMailer.account_activation(@user)
    assert_equal "[StuHub] Account Activation", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match @user.name,               mail.body.encoded
    assert_match @user.activation_token,   mail.body.encoded
    assert_match CGI::escape(@user.email), mail.body.encoded
  end

  test "check welcome email" do
    mail = UserMailer.welcome_email(@user)
    assert_equal "[StuHub] Welcome to StuHub!", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match CGI::escape(@user.email), mail.body.encoded
  end

  test "check password reset request email" do
    @user.reset_token = User.new_token
    mail = UserMailer.password_reset(@user)
    assert_equal "[StuHub] Password Reset Request", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match @user.reset_token,        mail.body.encoded
    assert_match CGI::escape(@user.email), mail.body.encoded
  end

  test "check password reset success email" do
    mail = UserMailer.password_reset_success(@user)
    assert_equal "[StuHub] Password Reset Successful", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
  end
end
