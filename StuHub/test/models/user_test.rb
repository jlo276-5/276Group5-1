require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Test User", email: "test@example.com",
                    password: "test123", password_confirmation: "test123")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 247 + "@test.com"
    assert_not @user.valid?
  end

  test "password should be present" do
    @user.password = @user.password_confirmation = "        "
    assert_not @user.valid?
  end

  test "password should be long enough" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "password should be match confirmation" do
    @user.password = "a" * 7
    @user.password_confirmation = "b" * 7
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "admin? and superuser? should return correct values" do
    assert_not @user.admin?
    @user.role = 1
    assert @user.admin?
    assert_not @user.superuser?
    @user.role = 2
    assert @user.superuser?
  end

  test "role_string should return correct value" do
    assert_equal "Standard", @user.role_string
    @user.role = 1
    assert_equal "Admin", @user.role_string
    @user.role = 2
    assert_equal "Super", @user.role_string
  end

  test "role should be valid" do
    @user.role = 3
    assert_not @user.valid?
  end

  test "name should always return a value" do
    @user.name = nil
    assert @user.valid?
    assert_equal "test", @user.name
    @user.name = "Test User"
    assert @user.valid?
    assert_equal "Test User", @user.name
  end

  test "create_reset_digest should generate digests" do
    @user.create_reset_digest
    assert_not_empty @user.reset_digest
    assert_not_empty @user.reset_token
  end

  test "reset_reset_digest should clear digests" do
    @user.create_reset_digest
    assert_not_empty @user.reset_digest
    @user.reset_reset_digest
    assert_nil @user.reset_digest
  end

  test "create_email_change_digest should generate digests" do
    @user.create_email_change_digest
    assert_not_empty @user.email_change_digest
  end

  test "reset_email_change_digest should clear digests" do
    @user.create_email_change_digest
    @user.email_change_new = "derp@example.com"
    assert @user.valid?
    assert_not_empty @user.email_change_new
    assert_equal "derp@example.com", @user.email_change_new
    assert_not_empty @user.email_change_digest

    @user.reset_email_change_digest
    assert @user.valid?
    assert_nil @user.email_change_new
  end

  test "should remember and forget" do
    @user.remember
    assert_not_empty @user.remember_digest
    @user.forget
    assert_nil @user.remember_digest
  end

  test "should expire password resets" do
    @user.reset_sent_at = Time.zone.now-3.hours
    assert @user.password_reset_expired?
  end

  test "should expire email changes" do
    @user.email_change_requested_at = Time.zone.now-3.hours
    assert @user.email_change_expired?
  end

  test "should be more powerful" do
    @user.role = 2
    user = users(:lana)
    assert @user.more_powerful(true, user)
  end

  test "should be at least as powerful" do
    @user.role = 2
    user = users(:superman)
    assert @user.more_powerful(false, user)
  end

end
