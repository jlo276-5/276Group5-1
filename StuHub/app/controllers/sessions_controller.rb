class SessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        flash[:success] = 'Successfully logged in.'
        redirect_back_or home_url
      else
        flash[:warning] = "This account is not activated. Please check your email for the activation link."
        redirect_to login_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    flash[:success] = 'Successfully logged out.'
    redirect_to root_url
  end
end
