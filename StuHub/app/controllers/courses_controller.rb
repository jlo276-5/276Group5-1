class CoursesController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :valid_institution
  before_action :valid_course, only: [:show, :info, :enrollment, :course_members, :resources, :new_resource, :create_resource, :get_resource, :edit_resource, :update_resource, :destroy_resource]
  before_action :verify_membership, only: [:show, :course_members, :resources, :new_resource, :create_resource, :get_resource, :edit_resource, :update_resource, :destroy_resource]
  before_action :valid_dropbox, only: [:new_resource, :create_resource]
  before_action :valid_resource, only: [:get_resource, :edit_resource, :update_resource, :destroy_resource]
  before_action :can_edit_resource, only: [:edit_resource, :update_resource, :destroy_resource]
  after_action :update_last_visited, only: [:show, :course_members, :resources, :new_resource, :get_resource, :edit_resource]
  layout 'course', only: [:show, :info, :enrollment, :course_members, :resources, :new_resource, :create_resource, :edit_resource, :update_resource, :destroy_resource]

  require 'rest-client'
  require 'date'

  def index
    @next_term = params[:next_term] == "true" ? true : false
    @institution = current_user.institution
    @term = @institution.current_term
    if @next_term
      if @term.nil?
        flash[:warning] = "Next Term Data not yet available"
        redirect_to courses_path
      end
      @term = @institution.next_term
    end
    if @term == nil
      flash[:danger] = "Your Institution has not set up their data properly. Please contact your Institution."
      redirect_to home_path
    elsif @term.updating
      if @next_term && !@institution.current_term.nil? && !@institution.current_term.updating
        flash[:warning] = "A Data Update is in progress for the next term, only the current term is available."
        redirect_to courses_path
      elsif !@next_term && !@institution.next_term.nil? && !@institution.next_term.updating
        flash[:warning] = "A Data Update is in progress for the next term, only the current term is available."
        redirect_to courses_path(next_term: true)
      else
        flash[:warning] = "A Data Update is in progress, please try again later."
        redirect_to home_path
      end
    elsif @term.data_mode == 1
      # XLSX DB
      @departments = get_departments_api(@term).order('name ASC')

      if !params[:department].to_s.blank?
        department = Department.find(params[:department])
        @courses = get_courses_api(department).order('number ASC')
        @department_select = params[:department]
      else
        @courses = []
      end
    else
      # MANUAL ENTRY
    end
  end

  def get_departments
    term = Term.find(params[:term_id])
    @departments = get_departments_api(term).order('name ASC')
  end

  def get_courses
    department = Department.find(params[:department_id])
    @courses = get_courses_api(department).order('number ASC')
  end

  def info
    @course = Course.find_by(id: params[:id])
    if @course.department.term.updating
      flash[:warning] = "A Data Update is in progress, please try again later."
      redirect_to home_path
    else
      @cm = current_user.course_memberships.find_by(course_id: @course.id)

      get_course_api(@course)
    end
  end

  def enrollment
    @course = Course.find_by(id: params[:id])

    @datasets = []

    unless @course.enrollment.blank?
      @course.enrollment.each do |key, value|
        actualValues = {}
        remainValues = {}
        maxValues = {}
        max = 0
        value.each do |v|
          unless v.nil?
            actualValues[v["date"].utc.strftime('%b %d, %Y')] = v["actual"].to_i
            maxValues[v["date"].utc.strftime('%b %d, %Y')] = v["max"].to_i
            remainValues[v["date"].utc.strftime('%b %d, %Y')] = (v["max"].to_i - v["actual"].to_i)
            if v["max"] > max
              max = v["max"]
            end
          end
        end
        @datasets << {"key" => key, "max" => max, "data" => [{name: "Capacity", data: maxValues},
                                                             {name: "Enrollment", data: actualValues},
                                                             {name: "Remaining", data: remainValues}]}
      end
    end
  end

  def show
    @course = Course.find_by(id: params[:id])

    get_course_api(@course)

    @chat_channel_type = 1;
    @post_channel_type = 1;
    @messages = Message.includes(:user).where(channel_type: @chat_channel_type, channel_id: @course.id).last(30)
    @posts = Post.includes(:user).where(channel_type: @post_channel_type, channel_id: @course.id).order('created_at DESC')
  end

  def course_members
    @course = Course.find_by(id: params[:id])
    @users = @course.users.paginate(page: params[:page], per_page: 25).order('created_at ASC')
  end

  def resources
    @course = Course.find_by(id: params[:id])
    @resources = CourseResource.where(course_id: params[:id])
  end

  def new_resource
    @course = Course.find_by(id: params[:id])
    @resource = CourseResource.new
  end

  def create_resource
    @resource = CourseResource.new(resource_params)
    @course = Course.find_by(id: params[:id])
    client = Dropbox::API::Client.new(token: current_user.dropbox_token, secret: current_user.dropbox_secret)

    if client.nil?
      flash[:danger] = "Invalid Connection to Dropbox. Please relink your account."
      redirect_to accounts_user_path(current_user)
    elsif params[:course_resource][:file].blank?
      @resource.errors.add(:base, "You must attach a file.")
      render 'new_resource'
    elsif !Resource.permitted_types.include?(params[:course_resource][:file].content_type)
      @resource.errors.add(:base, 'Files of this type are not permitted')
      render 'new_resource'
    else
      @resource.file_name = params[:course_resource][:file].original_filename
      @resource.content_type = params[:course_resource][:file].content_type
      @resource.course = @course
      @resource.user = current_user
      existing = nil
      begin
        client.find("CourseResources")
      rescue Dropbox::API::Error::NotFound
        client.mkdir("CourseResources")
      end
      begin
        existing = client.find("CourseResources/#{@resource.file_name}")
      rescue Dropbox::API::Error::NotFound
        existing = nil
      end
      begin
        if existing.nil? && (file = client.chunked_upload("CourseResources/#{@resource.file_name}", params[:course_resource][:file].tempfile)) && @resource.save
          @resource.update_attribute(:cached_url, file.share_url.url)
          flash[:success] = "New Course Resource Created: File \"#{@resource.file_name}\", Size #{number_to_human_size(file.bytes)}"
          redirect_to resources_course_path(@course)
        elsif !existing.nil?
          @resource.errors.add(:base, "There is already a file named #{@resource.file_name} in your Dropbox. Please name it something different.")
          render 'new_resource'
        else
          render 'new_resource'
        end
      rescue Dropbox::API::Error => e
        @resource.errors.add(:base, "Could not upload to Dropbox: #{e.message}.")
        render 'new_resource'
      end
    end
  end

  def get_resource
    @course = Course.find_by(id: params[:id])
    @resource = CourseResource.find_by(id: params[:resource_id])

    if @resource.cached_url and (code = RestClient.head(@resource.cached_url).code[0]) != 4 and code != 5
      redirect_to @resource.cached_url
    else
      if current_user.dropbox_token.blank? or current_user.dropbox_secret.blank? or (client = Dropbox::API::Client.new(token: current_user.dropbox_token, secret: current_user.dropbox_secret)).nil?
        flash[:danger] = "That Resource is no longer available."
        @resource.destroy
        redirect_to resources_course_path(@course)
      else
        begin
          file = client.find("CourseResources/#{@resource.file_name}")
          @resource.update_attribute(:cached_url, file.share_url.url)
          redirect_to @resource.cached_url
        rescue Dropbox::API::Error => e
          flash[:danger] = "That Resource is no longer available."
          @resource.destroy
          redirect_to resources_course_path(@course)
        end
      end
    end
  end

  def edit_resource
    @course = Course.find_by(id: params[:id])
    @resource = CourseResource.find_by(id: params[:resource_id])
  end

  def update_resource
    resource = CourseResource.find_by(id: params[:resource_id])
    if !params[:course_resource][:file].blank?
      @resource.errors.add(:base, "You cannot change the file that the Resource points to. Please create a new Resource.")
      render 'edit_resource'
    elsif resource.update_attributes(resource_params)
      flash.now[:success] = "Resource Updated"
      redirect_to resources_course_path(@course)
    else
      render 'edit_resource'
    end
  end

  def destroy_resource
    @course = Course.find_by(id: params[:id])
    resource = CourseResource.find_by(id: params[:resource_id])
    client = Dropbox::API::Client.new(token: resource.user.dropbox_token, secret: resource.user.dropbox_secret)
    if resource.destroy
      if resource.file_name.blank? or client.nil?
        flash[:warning] = "Resource Deleted, but could not delete file from Dropbox."
      else
        begin
          client.destroy("CourseResources/#{@resource.file_name}")
          flash[:success] = "Resource Deleted"
        rescue Dropbox::API::Error::NotFound
          flash[:success] = "Resource Deleted"
        rescue Dropbox::API::Error => e
          flash[:warning] = "Resource Deleted, but could not delete the file from Dropbox: #{e.message}."
        end
      end
    else
      flash[:danger] = "Could not delete Resource"
    end
    redirect_to resources_course_path(@course)
  end

  private

  def resource_params
    params.require(:course_resource).permit(:name, :description, :category)
  end

  def get_departments_api(term)
    departments = term.departments

    if departments.count == 0 or (Time.now-(departments.order('updated_at').last.updated_at)) > 1.month
      request_departments = JSON.parse(RestClient.get "#{term.data_url}?#{term.year}/#{term.name}")
      request_departments.each do |d|
        department_obj = term.departments.find_by(name: d["text"])
        if !department_obj
          department_obj = Department.new
          department_obj.name = d["text"]
          term.departments << department_obj
        else
          department_obj.touch
        end
      end
      term.save
    end

    return departments
  end

  def get_courses_api(department)
    courses = department.courses

    if courses.count == 0 or (Time.now-(courses.order('updated_at').last.updated_at)) > 2.weeks
      begin
        request_courses = JSON.parse(RestClient.get "#{department.term.data_url}?#{department.term.year}/#{department.term.name}/#{department.name}")
      rescue => e
        puts "#{department.term.data_url}?#{department.term.year}/#{department.term.name}/#{department.name}"
        puts e.response
        courses = []
        return
      end
      request_courses.each do |c|
        course_obj = department.courses.find_by(number: c["text"])
        if !course_obj
          course_obj = Course.new
          course_obj.number = c["text"]
          course_obj.name = c["title"]
          department.courses << course_obj
        else
          course_obj.touch
        end # !course_obj

        course_obj.save
      end # request_courses.each do
      department.save
    end # courses.count == 0 or (Time.now-(courses.order('updated_at').last.updated_at)) > 1.day

    return courses
  end

  def get_course_api(course)
    course.with_lock do
      if course.associated_classes.length == 0 or (Time.now-(course.associated_classes.order('updated_at').last.updated_at)) > 2.weeks
        sections_fetch_error_count = 0

        begin
          request_sections = JSON.parse(RestClient.get "#{course.department.term.data_url}?#{course.department.term.year}/#{course.department.term.name}/#{course.department.name}/#{course.number}")
        rescue => e
          puts "#{course.department.term.data_url}?#{course.department.term.year}/#{course.department.term.name}/#{course.department.name}/#{course.number}"
          puts e.response # Redo.
          if sections_fetch_error_count < 2
            sections_fetch_error_count += 1
            retry
          else
            flash[:danger] = "Could not load Course Details"
            return
          end
        end
        request_sections.each do |s|
          associated_class_obj = course.associated_classes.find_by(number: s["associatedClass"])
          if s["associatedClass"].blank?
            next
          end
          if !associated_class_obj
            associated_class_obj = AssociatedClass.new
            puts s["associatedClass"]
            associated_class_obj.number = s["associatedClass"]
            course.associated_classes << associated_class_obj
          end # !associated_class_obj

          section_obj = associated_class_obj.sections.find_by(key: s["text"])
          if !section_obj
            section_obj = Section.new
            section_obj.key = s["text"]
            section_obj.code = s["sectionCode"]
            associated_class_obj.sections << section_obj
          end # !section_obj

          section_fetch_error_count = 0

          begin
            request_section = JSON.parse(RestClient.get ("#{course.department.term.data_url}?#{course.department.term.year}/#{course.department.term.name}/#{course.department.name}/#{course.number}/#{section_obj.key}".downcase))
          rescue => e
            puts "#{course.department.term.data_url}?#{course.department.term.year}/#{course.department.term.name}/#{course.department.name}/#{course.number}/#{section_obj.key}".downcase
            puts e.response
            if section_fetch_error_count < 2
              section_fetch_error_count += 1
              retry
            else
              flash[:danger] = "Could not load some Course Details"
              next
            end
          end
          section_obj.unique_number = request_section["info"]["classNumber"]
          if course.name.blank?
            course.name = request_section["info"]["title"]
            course.save
          end # course_obj.name.blank?

          if request_section["courseSchedule"]
            request_section["courseSchedule"].each_with_index do |sched, index|
              next if (sched["startDate"].blank? or sched["startTime"].blank? or sched["days"].blank?)

              sectiontime_obj = section_obj.section_times[index]
              if !sectiontime_obj
                sectiontime_obj = SectionTime.new
                section_obj.section_times << sectiontime_obj
              else
                sectiontime_obj.touch
              end # !sectiontime_obj

              sectiontime_obj.start_date = Date.parse(sched["startDate"])
              sectiontime_obj.start_time = Time.parse(sched["startTime"])
              sectiontime_obj.end_date = Date.parse(sched["endDate"])
              sectiontime_obj.end_time = Time.parse(sched["endTime"])
              sectiontime_obj.days = sched["days"]
              sectiontime_obj.building = sched["buildingCode"]
              sectiontime_obj.room = sched["roomNumber"]
              sectiontime_obj.campus = sched["campus"]
              sectiontime_obj.save
            end # request_section["courseSchedule"].each_with_index

            while section_obj.section_times.length > request_section["courseSchedule"].length do
              section_obj.section_times.last.destroy
            end
          end # request_section["courseSchedule"]

          if request_section["examSchedule"]
            request_section["examSchedule"].each_with_index do |exam, index|
              next if (exam["startDate"].blank? or exam["startTime"].blank?)

              exam_obj = section_obj.exams[index]
              if !exam_obj
                exam_obj = Exam.new
                section_obj.exams << exam_obj
              else
                exam_obj.touch
              end # !exam_obj

              time_start = Time.parse(exam["startTime"])
              time_end = Time.parse(exam["endTime"])

              exam_obj.exam_start = DateTime.parse(exam["startDate"]).change({hour: time_start.hour, min: time_start.min})
              exam_obj.exam_end = DateTime.parse(exam["endDate"]).change({hour: time_end.hour, min: time_end.min})
              exam_obj.building = exam["buildingCode"]
              exam_obj.room = exam["roomNumber"]
              exam_obj.campus = exam["campus"]
              exam_obj.save
            end # request_section["examSchedule"].each_with_index

            while section_obj.exams.length > request_section["examSchedule"].length do
              section_obj.exams.last.destroy
            end
          end # request_section["examSchedule"]

          if request_section["instructor"]
            request_section["instructor"].each_with_index do |instr, index|
              next if (instr["firstName"].blank? or instr["lastName"].blank?)

              instructor_obj = section_obj.instructors[index]
              if !instructor_obj
                instructor_obj = Instructor.new
                section_obj.instructors << instructor_obj
              else
                instructor_obj.touch
              end # !instructor_obj

              instructor_obj.first_name = instr["firstName"]
              instructor_obj.last_name = instr["lastName"]
              instructor_obj.email = instr["email"]
              instructor_obj.office = instr["office"]
              instructor_obj.office_hours = instr["officeHours"]
              instructor_obj.phone = instr["phone"]
              instructor_obj.website = instr["profileUrl"]
              instructor_obj.save
            end # request_section["instructors"].each_with_index

            while section_obj.instructors.length > request_section["instructor"].length do
              section_obj.instructors.last.destroy
            end
          end # request_section["instructors"]

          section_obj.save
          associated_class_obj.save
        end # request_sections.each
        course.save
      end
    end

    return course
  end

  def valid_institution
    @institution = current_user.institution
    if @institution.nil?
      flash[:danger] = "You must be associated with an Institution to access Courses. Contact an Administrator if you need help."
      redirect_to home_path
    end
  end

  def valid_course
    @course = Course.find_by(id: params[:id])
    if @course.nil?
      flash[:danger] = "No such course exists with an id #{params[:id]}"
      redirect_to courses_path
    end
  end

  def valid_dropbox
    @course = Course.find_by(id: params[:id])

    unless !(current_user.dropbox_token.blank? or current_user.dropbox_secret.blank? or (client = Dropbox::API::Client.new(token: current_user.dropbox_token, secret: current_user.dropbox_secret)).nil?)
      flash[:warning] = "You must connect your account to Dropbox to upload files."
      redirect_to resources_course_path(@course)
    end
  end

  def valid_resource
    @course = Course.find_by(id: params[:id])
    @resource = CourseResource.find_by(id: params[:resource_id])
    if @resource.nil? or @resource.course != @course
      flash[:danger] = "No such resource exists with an id #{params[:resource_id]}"
      redirect_to resources_course_path(@course)
    end
  end

  def can_edit_resource
    @course = Course.find_by(id: params[:id])
    @resource = CourseResource.find_by(id: params[:resource_id])
    unless (!@resource.user.nil? and current_user?(@resource.user)) or current_user.admin?
      flash[:danger] = "You do not have the permission to do that."
      redirect_to resources_course_path(@course)
    end
  end

  def verify_membership
    @course = Course.find_by(id: params[:id])
    if @course and !current_user.memberOfCourse?(@course)
      flash[:warning] = "You are not a member of this course yet."
      redirect_to get_info_course_path(@course)
    end
  end

  def update_last_visited
    gm = CourseMembership.find_by(course_id: params[:id], user_id: current_user.id)
    unless gm.nil?
      gm.touch :last_visited_at
    end
  end
end
