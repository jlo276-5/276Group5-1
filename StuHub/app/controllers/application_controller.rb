class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  before_filter :require_login
  before_filter :maintenance_mode
  before_filter :maintenance_message
  before_filter :update_last_active
  before_filter :set_time_zone

  private

  def maintenance_message
    if StuHubSettings.maintenance_mode
      flash.now[:info] = "StuHub is currently in Maintenance Mode."
      unless StuHubSettings.maintenance_message.blank?
        flash.now[:info] += "<br>Message from Administrators: <strong>#{StuHubSettings.maintenance_message}</strong>"
      end
    end
  end

  def require_login
    unless current_user
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def maintenance_mode
    if StuHubSettings.maintenance_mode
      if logged_in? and !current_user.admin?
        log_out
      end
      if !current_user
        redirect_to root_path
      end
    end
  end

  def update_last_active
    if current_user
      current_user.touch :last_active_at
    end
  end

  def set_time_zone
    Time.zone = current_user.time_zone if current_user
  end
end
