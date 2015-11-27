class ResourcesController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
    @resources = @course.resources
  end

  def new
  end

  def edit
  end
end
