class HomeController < ApplicationController
  def home
    if !(logged_in?)
      redirect_to root_path
    else
      @user = current_user
    end
  end
end
