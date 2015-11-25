class EmailChangesController < ApplicationController
  skip_before_filter :require_login
  before_filter :valid_user
  before_filter :check_expiration

  def edit
    user = User.find_by(email: params[:email])
    if user && user.activated? && user.authenticated?(:email_change, params[:id])
      old_email = user.email
      user.update_attribute(:email, user.email_change_new)
      user.reset_email_change_digest
      flash[:success] = "Your email has been changed. Please update any password managers."
      UserMailer.email_change_success(user, old_email).deliver_now
      redirect_to user
    else
      flash[:danger] = "Invalid activation link. Please verify that the link is correct."
      redirect_to root_url
    end
  end

  private

  # make sure valid user
  def valid_user
    @user = User.find_by(email: params[:email])
    unless (@user && @user.activated? &&
            @user.authenticated?(:email_change, params[:id]))
      flash[:danger] = "This email change link is invalid."
      redirect_to root_url
    end
  end

  # see if password expires
  def check_expiration
    if @user.email_change_expired?
      @user.reset_email_change_digest
      flash[:danger] = "This email change link has expired. Please request a new one."
      redirect_to edit_user_path(@user)
    end
  end
end
