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

  test "check password change success email" do
    mail = UserMailer.password_change_success(@user)
    assert_equal "[StuHub] Password Changed", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
  end

  test "check email change email" do
    @user.email_change_token = User.new_token
    mail = UserMailer.email_change(@user)
    @user.email_change_new = "testtest@example.com"
    assert_equal "[StuHub] Email Change Request", mail.subject
    assert_equal [@user.email_change_new], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match @user.email_change_token, mail.body.encoded
  end

  test "check email change success email" do
    mail = UserMailer.email_change_success(@user, "testtest@example.com")
    assert_equal "[StuHub] Email Change Successful", mail.subject
    assert_not_equal ["test@example.com"], mail.to
    assert_equal ["testtest@example.com"], mail.to
    assert_equal ["noreply@example.com"], mail.from
  end

  test "check promotion email" do
    @user.role = 2
    mail = UserMailer.promotion(@user, "Administrator")
    assert_equal "[StuHub] Account Promotion", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match @user.role_string_long, mail.body.encoded
end

  test "check demotion email" do
    @user.role = 0
    mail = UserMailer.demotion(@user, "Administrator")
    assert_equal "[StuHub] Account Demotion", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match @user.role_string_long, mail.body.encoded
end

  test "check deletion email" do
    mail = UserMailer.account_deletion(@user)
    assert_equal "[StuHub] Account Deletion", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
  end

  test "check locked email" do
    mail = UserMailer.account_locked(@user)
    assert_equal "[StuHub] Account Locked", mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
  end

end
