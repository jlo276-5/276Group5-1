class CourseMembershipsController < ApplicationController
  before_action :valid_cm, only: [:join_success, :add_section, :remove_section, :destroy]
  before_action :correct_user, only: [:join_success, :add_section, :remove_section, :destroy]

  def create
    course = Course.find(params[:course_id])
    user = User.find(params[:user_id])
    if !user.courses.find_by(id: course.id).nil?
      flash[:warning] = "You are already a member of this course."
      redirect_to get_info_course_path(course)
    else
      @cm = CourseMembership.new(course: course, user: user)
      @cm.join_date = DateTime.now
      if @cm.save
        if user.notification_emails
          CourseMailer.joined_course(user, course).deliver_now
        end
        redirect_to join_success_course_membership_path(@cm)
      else
        flash[:danger] = "Could not create Course Membership"
        redirect_to courses_path
      end
    end
  end

  def join_success
    @cm = CourseMembership.find(params[:id])
  end

  def add_section
    cm = CourseMembership.find(params[:id])
    section = Section.find(params[:section_id])
    if section.associated_class.course.id != cm.course.id
      flash[:danger] = "Invalid Membership Request"
      return if redirect_to courses_path
    elsif !cm.sections.find_by(id: section.id).nil?
      flash[:warning] = "You have already added this section."
    else
      flash[:success] = "Section Added to Course Membership"
      cm.sections << section
    end
    redirect_to get_info_course_path(cm.course)
  end

  def remove_section
    cm = CourseMembership.find(params[:id])
    if cm.sectionInMembership?(params[:section_id])
      cm.sections.delete(params[:section_id])
      flash[:success] = "Section Removed from Course Membership"
    else
      flash[:danger] = "No such Section on this Course Membership."
  end
    redirect_to get_info_course_path(cm.course)
  end

  def destroy
    cm = CourseMembership.find(params[:id])
    cm.destroy
    if cm.user.notification_emails
      CourseMailer.dropped_course(cm.user, cm.course).deliver_now
    end
    flash[:success] = "Dropped Course #{cm.course.course_number}"
    redirect_to courses_path
  end

  private

  def valid_cm
    @cm = CourseMembership.find_by(id: params[:id])
    if @cm.nil?
      flash[:danger] = "No such Course Membership Exists"
      redirect_to home_path
    end
  end

  def correct_user
    @cm = CourseMembership.find_by(id: params[:id])
    unless (current_user?(@cm.user) or current_user.more_powerful(true, cm.user))
      flash[:danger] = "You do not have the permission to do that."
      redirect_to courses_path
    end
  end
end
