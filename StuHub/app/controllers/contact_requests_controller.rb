class ContactRequestsController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create]
  skip_before_filter :maintenance_mode, only: [:new, :create]
  before_filter :valid_cr, only: [:show, :destroy, :resolve]
  layout 'admin', except: [:new, :create]

  def index
    if params[:resolved] == "true"
      @contact_requests = ContactRequest.where("resolved = true").paginate(page: params[:page], per_page: 25).order('created_at ASC')
    else
      @contact_requests = ContactRequest.where("resolved = false").paginate(page: params[:page], per_page: 25).order('created_at ASC')
    end
  end

  def show
    @cr = ContactRequest.find_by(id: params[:id])
  end

  def new
    @cr = ContactRequest.new
  end

  def create
    @cr = ContactRequest.new(cr_params)
    if verify_recaptcha(model: @cr, message: "reCAPTCHA check failed. Try again.") and @cr.save
      flash[:success] = "Your Contact Request has been submitted. If you requested a reply, expect one within a few days."
      redirect_to help_path
    else
      render 'new'
    end
  end

  def destroy
    cr = ContactRequest.find_by(id: params[:id])
    cr.destroy
    flash[:success] = "Contact Request ##{cr.id} Deleted"
    redirect_to contact_requests_path
  end

  def resolve
    @cr = ContactRequest.find_by(id: params[:id])
    if @cr.resolved
      flash[:warning] = "Contact Request ##{@cr.id} has already been marked as resolved."
      redirect_to contact_requests_path
    elsif @cr.update_attribute(:resolved, true)
      flash[:success] = "Contact Request ##{@cr.id} marked as resolved."
      redirect_to contact_requests_path
    else
      flash[:danger] = "Could not mark Contact Request ##{@cr.id} as resolved."
      redirect_to @cr
    end
  end

  private

  def cr_params
    params.require(:contact_request).permit(:name, :email, :contact_type, :title, :body, :reply)
  end

  def valid_cr
    @cr = ContactRequest.find_by(id: params[:id])
    if @cr.nil?
      flash[:danger] = "Invalid Contact Request ID ##{@cr.id}"
      redirect_to contact_requests_path
    end
  end
end
