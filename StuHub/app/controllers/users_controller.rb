class UsersController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create]
  before_action :correct_user_limited, only: :accounts
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  before_action :check_privacy,  only: [:show, :edit, :customize, :courses, :groups]

  ## Use 'find' method to show certain user
  def show
    @user = User.find_by id:params[:id]
    if (@user.nil?)
      flash[:danger] = "No user exists with an id #{params[:id]}."
      redirect_to users_url
    end
  end

  def index
    if current_user.admin?
      @users = User.paginate(page: params[:page], per_page: 25).order('created_at ASC')
    else
      @users = User.where(institution_id: current_user.id).paginate(page: params[:page], per_page: 25).order('created_at ASC')
    end
  end

  def new
    if current_user
      redirect_to home_url
    end
    @user = User.new
    @disable_institution = false
    if !params[:institution_id].nil? and !params[:cas_identifier].nil?
      @user.institution_id = params[:institution_id].to_i
      @user.cas_identifier = params[:cas_identifier]
      @disable_institution = true
    end
  end

  def create
    @user = User.new(user_params)
    if @user.cas_identifier == ""
      @user.cas_identifier = nil
    end
    if verify_recaptcha(model: @user, message: "reCAPTCHA check failed. Try again.") and @user.save
      @user.send_activation_email
      @user.privacy_setting = PrivacySetting.new
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      @user.tos_agree = false
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

  def customize
    @user = User.find_by id:params[:id]
    if (@user.nil?)
      flash[:danger] = "No user exists with an id #{params[:id]}."
      redirect_to users_url
    elsif !current_user?(@user) and !current_user.more_powerful(true, @user)
      flash[:danger] = "You do not have the permission to do that."
      redirect_to @user
    end
  end

  def accounts
    @user = User.find_by id:params[:id]
    if (@user.nil?)
      flash[:danger] = "No user exists with an id #{params[:id]}."
      redirect_to users_url
    elsif !current_user?(@user) and !current_user.superuser?
      flash[:danger] = "You do not have the permission to do that."
      redirect_to @user
    end

    if !@user.dropbox_uid.nil?
      client = Dropbox::API::Client.new(token: @user.dropbox_token, secret: @user.dropbox_secret)
      @dropbox_display_name = "#{client.account.display_name} [#{@user.dropbox_uid}]"
    end
  end

  def promote
    @user = User.find_by id:params[:id]
    if (!@user.more_powerful(false, current_user) and @user.role < 2)
      old_role = @user.role_string_long
      @user.role += 1
      if @user.save
        flash[:success] = "Promoted #{@user.name} from #{old_role} to #{@user.role_string_long}"
        UserMailer.promotion(@user, old_role).deliver_now
      else
        flash[:danger] = "Could not promote #{@user.name}"
      end
      redirect_to admin_users_path
    else
      flash[:danger] = "You do not have the permission to do that."
      redirect_to home_path
    end
  end

  def demote
    @user = User.find_by id:params[:id]
    if (!@user.more_powerful(false, current_user) and @user.role > 0)
      old_role = @user.role_string_long
      @user.role -= 1
      if @user.save
        flash[:success] = "Demoted #{@user.name} from #{old_role} to #{@user.role_string_long}"
        UserMailer.demotion(@user, old_role).deliver_now
      else
        flash[:danger] = "Could not demote #{@user.name}"
      end
      redirect_to admin_users_path
    else
      flash[:danger] = "You do not have the permission to do that."
      redirect_to home_path
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
    elsif params.has_key?(:new_email)
      user = @user.try(:authenticate, params[:current_password])
      if !user && !current_user.more_powerful(true, @user)
        @user.errors[:current_password] = 'is incorrect.'
        render 'edit'
      elsif (user || current_user.more_powerful(true, @user))
        if !params[:new_email].blank?
          if current_user.more_powerful(true, @user)
            params[:user][:email] = params[:new_email]
          else
            user.create_email_change_digest
            params[:user][:email_change_new] = params[:new_email]
          end
        end
        if @user.update_attributes(user_params)
          if !params[:user][:email_change_new].blank?
            flash[:success] = "Account Updated. Please check your email for a confirmation."
            @user.send_email_change_email
          else
            flash[:success] = "Account Updated. Please update your records."
          end
          if !params[:user][:password_confirmation].blank?
            @user.send_password_change_success_email
          end
          redirect_to @user
        else
          render 'edit'
        end
      else
        render 'edit'
      end
    elsif params[:user].has_key?(:name)
      if params[:user][:name].blank?
        params[:user][:name] = nil
      end
      if @user.update_attributes(customization_params)
        flash[:success] = "Profile Updated"
        redirect_to @user
      else
        render 'customize'
      end
    else
      render 'show'
    end
  end

  def courses
    @user = User.find_by id:params[:id]
    if (@user.nil?)
      flash[:danger] = "No user exists with an id #{params[:id]}."
      redirect_to users_url
    elsif !current_user?(@user) and !@user.privacy_setting.display_courses and !current_user.more_powerful(true, @user)
      flash[:danger] = "You do not have the permission to view that."
      redirect_to @user
    end
  end

  def groups
    @user = User.find_by id:params[:id]
    if (@user.nil?)
      flash[:danger] = "No user exists with an id #{params[:id]}."
      redirect_to users_url
    elsif !current_user?(@user) and !@user.privacy_setting.display_groups and !current_user.more_powerful(true, @user)
      flash[:danger] = "You do not have the permission to view that."
      redirect_to @user
    end
  end

  def schedule
    @user = current_user
  end

  private

    def user_params
      params.require(:user).permit(:email, :email_change_new, :password, :password_confirmation, :institution_id, :cas_identifier, :tos_agree)
    end

    def customization_params
      params.require(:user).permit(:name, :major, :about_me, :website, :birthday, :gender, :time_zone, :account_emails, :notification_emails, privacy_setting_attributes: [:id, :display_institution, :display_major, :display_about_me, :display_email, :display_website, :display_birthday, :display_gender, :display_courses, :display_groups])
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

    def correct_user_limited
      @user = User.find_by id:params[:id]
      unless (current_user?(@user) or current_user.superuser?)
        flash[:danger] = "You do not have the permission to do that."
        redirect_to(users_url)
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

    def check_privacy
      @user = User.find_by id:params[:id]
      if @user and @user.privacy_setting.nil?
        @user.privacy_setting = PrivacySetting.new
      end
    end
end
