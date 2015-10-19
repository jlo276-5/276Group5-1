class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "[StuHub] Account Activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
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
    mail to: user.email, subject: '[StuHub] Account Password Reset Successful'
  end

end
