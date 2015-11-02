class UsersController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  ## Use 'find' method to show certain user
  def show
    @user = User.find_by id:params[:id]
    if (@user.nil?)
      flash[:danger] = "No user exists with an id #{params[:id]}."
      redirect_to users_url
    end
  end

  def index
    @userscount = User.all.count
    @users = User.paginate(page: params[:page], per_page: 25).order('created_at ASC')
  end

  def new
    if current_user
      redirect_to home_url
    end
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def destroy
    user = User.find(params[:id])
    if current_user.more_powerful(true, user)
      user.destroy
      flash[:success] = "User Deleted"
      redirect_to users_url
    else
      flash[:danger] = "You do not have the permission to do that."
      redirect_to user
    end
  end

  def edit
    @user = User.find_by id:params[:id]
    if (@user.nil?)
      flash[:danger] = "No user exists with an id #{params[:id]}."
      redirect_to users_url
    elsif !current_user?(@user) and !current_user.more_powerful(true, @user)
      flash[:danger] = "You do not have the permission to do that."
      redirect_to @user
    end
  end

  def update
    @user = User.find_by id:params[:id]
    if (@user.nil?)
      flash[:danger] = "No user exists with an id #{params[:id]}."
      redirect_to users_url
    elsif !current_user?(@user) and !current_user.more_powerful(true, @user)
      flash[:danger] = "You do not have the permission to do that."
      redirect_to @user
    elsif @user.update_attributes(user_params)
      flash[:success] = "Profile Updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :time_zone)
    end

    # Filters
    # ensure logged in
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # ensure correct or admin or super user for editing and updating
    def correct_user
      @user = User.find_by id:params[:id]
      unless (current_user?(@user) or current_user.admin? or current_user.superuser?)
        flash[:danger] = "You do not have the permission to do that."
        redirect_to(users_url)
      end
    end

    # ensure admin or super user for deleting
    def admin_user
      unless (current_user.admin? or current_user.superuser?)
        flash[:danger] = "You do not have the permission to do that."
        redirect_to(users_url)
      end
    end
end
