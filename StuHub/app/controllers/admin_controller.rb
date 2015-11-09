class AdminController < ApplicationController
  before_filter :admin_user

  def index
  end

  def user_management
    @users = User.paginate(page: params[:page], per_page: 25).order('created_at ASC')
  end

  private

  # ensure admin or super user for deleting
  def admin_user
    unless current_user.admin?
      flash[:danger] = "You do not have the permission to see that."
      redirect_to home_path
    end
  end
end
