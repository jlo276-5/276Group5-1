class IndexController < ApplicationController
  skip_before_filter :require_login
  def index
    if !current_user
      @user = User.new
    else
      redirect_to home_path
    end
  end
end
