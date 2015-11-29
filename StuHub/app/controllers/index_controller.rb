class IndexController < ApplicationController
  skip_before_filter :require_login
  skip_before_filter :maintenance_mode

  def index
    if current_user and (!StuHubSettings.maintenance_mode or current_user.admin?)
      redirect_to home_path
    else
      @user = User.new
    end
  end
end
