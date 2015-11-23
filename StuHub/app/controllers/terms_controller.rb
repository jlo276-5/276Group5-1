class TermsController < ApplicationController
  before_action :valid_institution
  before_action :valid_term, except: [:new, :create]
  layout 'admin'

  require 'net/http'
  require 'creek'

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
      flash[:info] = "Term created."
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
      flash[:success] = "Term Updated"
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
    institution = Institution.find_by id:params[:institution_id]

    numberAdded = 0
    if term.data_mode == 1
      uri = URI.parse(term.database_url)
      Net::HTTP.start(uri.host, uri.port) do |http|
        data = http.get(uri.path)
        temp = Tempfile.open("db-#{institution.id}-#{term.term_reference}.xlsx")
        begin
          temp.binmode
          temp.write(data.body)
          temp.flush

          workbook = Creek::Book.new temp, check_file_extension: false
          rows = workbook.sheets.first.rows.to_a
          rows.shift(6)

          rows.each do |row|
            values = row.values
            department = term.departments.find_by(name: values[2])
            if department.nil?
              department = Department.new(name: values[2])
              term.departments << department
            end

            course = department.courses.find_by(number: values[3])
            if course.nil?
              course = Course.new(number: values[3], name: values[6])
              department.courses << course
              numberAdded += 1
            end

            department.save!
          end

          term.save!
        ensure
          temp.close
          temp.unlink
        end
      end

      term.touch :data_last_updated
      flash[:success] = "Term \"#{term.term_name}\" Data Updated: Total # Departments = #{term.departments.size}, Total # Courses = #{term.courses.size}, # Courses Added = #{numberAdded}"
    else
      flash[:danger] = "That Term does not use an XLSX DB for its data."
    end
    redirect_to institution_path(id: term.institution.id)
  end

  private

  def term_params
    params.require(:term).permit(:name, :year, :term_reference, :data_mode, :data_url, :database_url, :database_contains_enrollment, :enrollment_start_date, :start_date, :end_date, :exams_end_date)
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
