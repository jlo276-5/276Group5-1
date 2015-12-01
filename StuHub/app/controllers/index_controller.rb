class IndexController < ApplicationController
  skip_before_filter :require_login
  skip_before_filter :maintenance_mode
  layout 'blank', only: [:new_index]

  def index
    if current_user and (!StuHubSettings.maintenance_mode or current_user.admin?)
      redirect_to home_path
    elsif StuHubSettings.new_landing_page
      redirect_to new_index_path
    else
      @user = User.new
    end
  end

  def new_index
    if current_user and (!StuHubSettings.maintenance_mode or current_user.admin?)
      redirect_to home_path
    elsif !StuHubSettings.new_landing_page
      redirect_to root_path
    else
      @user = User.new
    end
  end

end
