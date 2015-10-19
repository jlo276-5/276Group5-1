class PasswordResetsController < ApplicationController
  skip_before_filter :require_login
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "An email sent to the specified email address with password reset instructions."
      redirect_to root_url
    else
      flash.now[:danger] = "No user with such an email address was found."
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      flash.now[:danger] = "Passwords cannot be empty."
      render 'edit'
    elsif @user.update_attributes(user_params)
      flash[:success] = "Your password has been reset. Please log in now to verify."
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
              !@user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # see if password expires
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "This password reset link has expired. Please request a new one."
        redirect_to new_password_reset_url
      end
    end
end
