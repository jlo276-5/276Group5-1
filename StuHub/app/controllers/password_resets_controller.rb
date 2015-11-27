class PasswordResetsController < ApplicationController
  skip_before_filter :require_login
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
    if current_user # Redirect to user page when already logged in
      redirect_to current_user
    end
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
    end
    flash[:info] = "If an account with the specified email address exists, an email has been sent with password reset instructions."
    redirect_to root_url
  end

  def edit
    if current_user # Redirect to user page when already logged in
      redirect_to current_user
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      @user.reset_reset_digest
      @user.unlock_account
      flash[:success] = "Your password has been reset. Please login to verify."
      UserMailer.password_reset_success(@user).deliver_now
      redirect_to login_url
    else
      render 'edit'
    end
  end

   private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    #filter before action

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # make sure valid user
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        flash[:danger] = "This password reset link is invalid."
        redirect_to root_url
      end
    end

    # see if password expires
    def check_expiration
      if @user.password_reset_expired?
        @user.reset_reset_digest
        flash[:danger] = "This password reset link has expired. Please request a new one."
        redirect_to new_password_reset_url
      end
    end
end
