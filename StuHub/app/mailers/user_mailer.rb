class UserMailer < ApplicationMailer

  # Subjects can be set in your I18n file at config/locales/en.yml
  # with:
  #   en.user_mailer.<mail>.subject

  def account_activation(user)
    @user = user
    mail to: user.email, subject: "[StuHub] Account Activation"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "[StuHub] Account Password Reset Request"
  end

  def welcome_email(user)
    @user = user
    mail to: user.email, subject: '[StuHub] Welcome to StuHub!'
  end

  def password_reset_success(user)
    @user = user
    mail to: user.email, subject: '[StuHub] Password Reset Successful'
  end

  def password_change_success(user)
    @user = user
    mail to: user.email, subject: '[StuHub] Password Changed'
  end

  def email_change(user)
    @user = user
    mail to: user.email_change_new, subject: '[StuHub] Email Change Request'
  end

  def email_change_success(user, old_email)
    @user = user
    mail to: user.email, subject: '[StuHub] Email Change Successful'
    mail to: old_email, subject: '[StuHub] Email Change Successful'
  end

  def promotion(user, old_role)
    @user = user
    @old_role = old_role
    mail to: user.email, subject: '[StuHub] Account Promotion'
  end

  def demotion(user, old_role)
    @user = user
    @old_role = old_role
    mail to: user.email, subject: '[StuHub] Account Demotion'
  end

  def account_deletion(user)
    @user = user
    mail to: user.email, subject: '[StuHub] Account Deletion'
  end

end
