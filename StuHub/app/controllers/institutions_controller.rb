class InstitutionsController < ApplicationController
  before_action :super_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :admin_user, only: [:index]
  layout 'admin', only: [:new, :index, :edit]

  def new
    @institution = Institution.new
  end

  def index
  end

  def show
    @institution = Institution.find_by id:params[:id]
    if (@institution.nil?)
      flash[:danger] = "No institution exists with an id #{params[:id]}."
      redirect_to current_user.admin? ? institutions_path : home_path
    end
    @users = @institution.users.paginate(page: params[:page], per_page: 25).order('created_at ASC')
  end

  def create
    @institution = Institution.new(institution_params)
    if @institution.save
      flash[:info] = "Institution created."
      redirect_to institutions_path
    else
      render 'new'
    end
  end

  def edit
    @institution = Institution.find_by id:params[:id]
    if (@institution.nil?)
      flash[:danger] = "No institution exists with an id #{params[:id]}."
      redirect_to institutions_path
    end
  end

  def update
    @institution = Institution.find_by id:params[:id]
    if (@institution.nil?)
      flash[:danger] = "No institution exists with an id #{params[:id]}."
      redirect_to institutions_path
    elsif @institution.update_attributes(institution_params)
      flash[:success] = "Institution Updated"
      redirect_to institutions_path
    else
      render 'edit'
    end
  end

  def destroy
    institution = Institution.find_by id:params[:id]
    if (@institution.nil?)
      flash[:danger] = "No institution exists with an id #{params[:id]}."
    else
      institution.destroy
      flash[:success] = "Institution Deleted"
    end
    redirect_to institutions_path
  end

  private

  def institution_params
    params.require(:institution).permit(:name, :state, :city, :country, :email_constraint, :website, :image, :uses_cas, :cas_endpoint)
  end

  def admin_user
    unless current_user.admin?
      flash[:danger] = "You do not have the permission to do that."
      redirect_to home_path
    end
  end

  def super_user
    unless current_user.superuser?
      flash[:danger] = "You do not have the permission to do that."
      redirect_to home_path
    end
  end
end
