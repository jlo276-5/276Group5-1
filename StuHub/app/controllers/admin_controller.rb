class AdminController < ApplicationController
  before_filter :admin_user

  def index
  end

  private

  # ensure admin or super user for deleting
  def admin_user
    unless current_user.admin?
      flash[:danger] = "You do not have the permission to do that."
      redirect_to home_path
    end
  end
end
