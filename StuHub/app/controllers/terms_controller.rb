class TermsController < ApplicationController
  before_action :valid_institution
  before_action :valid_term, except: [:new, :create]
  before_action :not_updating, except: [:new, :create]
  layout 'admin'

  def new
    @institution = Institution.find(params[:institution_id])
    @term = Term.new(institution_id: @institution.id)
  end

  def create
    @institution = Institution.find(params[:institution_id])
    @term = Term.new(term_params)
    @term.institution = @institution
    if @term.save
      if @institution.current_term == nil
        @institution.current_term_id = @term.id
        @institution.save
      end
      flash[:info] = "Term Created. If you enabled database seeding, click Update."
      redirect_to institution_path(id: @institution.id)
    else
      render 'new'
    end
  end

  def edit
    @term = Term.find_by id:params[:id]
  end

  def update
    @term = Term.find_by id:params[:id]
    if @term.update_attributes(term_params)
      if @term.database_url.blank?
        @term.update_attributes(:data_last_updated => nil, :database_last_line => 0)
      end
      flash[:success] = "Term Updated.  If you enabled database seeding, click Update."
      redirect_to institution_path(id: @term.institution.id)
    else
      render 'edit'
    end
  end

  def destroy
    term = Term.find_by id:params[:id]
    term.destroy
    flash[:success] = "Term Deleted"
    redirect_to institution_path(id: term.institution.id)
  end

  def update_data
    term = Term.find_by id:params[:id]

    if term.data_mode == 1
      term.update_attribute(:updating, true)

      UpdateTerm.perform_later(term)
      flash[:success] = "A Database Update for Term #{term.term_name_long} has been scheduled."
    else
      flash[:danger] = "That Term does not use an XLSX DB for its data."
    end
    redirect_to institution_path(id: term.institution.id)
  end

  private

  def term_params
    params.require(:term).permit(:name, :year, :term_reference, :data_mode, :data_url, :database_url, :database_contains_enrollment, :enrollment_start_date, :start_date, :end_date, :exams_end_date)
  end

  def not_updating
    term = Term.find_by(id: params[:id])
    if term.updating
      flash[:warning] = "This Term is currently scheduled to receive a Database Update. Please wait until that has finished."
      redirect_to institution_path(id: params[:institution_id])
    end
  end

  def valid_institution
    institution = Institution.find_by(id: params[:institution_id])
    unless !institution.nil?
      flash[:danger] = "No institution exists with an id #{params[:institution_id]}."
      redirect_to institutions_path
    end
  end

  def valid_term
    institution = Institution.find_by(id: params[:institution_id])
    term = Term.find_by(id: params[:id])
    unless (!institution.nil? and !term.nil?) and (term.institution_id == institution.id)
      flash[:danger] = "No term exists for the given parameters."
      redirect_to institution_path(id: params[:institution_id])
    end
  end
end
