# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

   # Preview these email at http://localhost:3000/rails/mailers/user_mailer
  def account_activation
     user = User.first
     user.activation_token = User.new_token
     UserMailer.account_activation(user)
  end

  def password_reset
     user = User.first
     user.reset_token = User.new_token
     UserMailer.password_reset(user)
   end

   def welcome_email
     user = User.first
     UserMailer.welcome_email(user)
   end

   def password_reset_success
     user = User.first
     UserMailer.password_reset_success(user)
  end

  def password_change_success
    user = User.first
    UserMailer.password_change_success(user)
  end

  def email_change
    user = User.first
    user.email_change_token = User.new_token
    UserMailer.email_change(user)
  end

  def email_change_success
    user = User.first
    old_email = "test@example.com"
    UserMailer.email_change_success(user, old_email)
  end

  def promotion
    user = User.first
    old_role = "Test"
    UserMailer.promotion(user, old_role)
  end

  def demotion
    user = User.first
    old_role = "Test"
    UserMailer.demotion(user, old_role)
  end

  def account_deletion
    user = User.first
    UserMailer.account_deletion(user)
  end

end
