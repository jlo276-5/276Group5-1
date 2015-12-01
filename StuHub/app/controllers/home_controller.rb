class HomeController < ApplicationController
  def home
    @current_course_memberships = current_user.current_course_memberships.sort_by {|x| [-(x.course.term.year), -(x.course.term.term_order), x.course.department.name, x.course.number]}
    @next_course_memberships = current_user.next_course_memberships.sort_by {|x| [-(x.course.term.year), -(x.course.term.term_order), x.course.department.name, x.course.number]}
    if current_user.institution
      @posts = Post.includes(:user).where(channel_type: 3, channel_id: current_user.institution.id).order('created_at DESC').last(30)
    end
  end
end
