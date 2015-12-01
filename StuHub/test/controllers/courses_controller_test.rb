require 'test_helper'

class CoursesControllerTest < ActionController::TestCase

  def setup
    @user = users(:archer)
    @superuser = users(:superman)
    @cm = course_memberships(:one)
    @course = courses(:courseone)
    @coursetwo = courses(:coursetwo)
  end

  test "should show index with departments" do
    log_in_as(@user)
    get :index
    assert_template :index
    assert_select 'select.department_select' do |elements|
      assert_select 'option', range: 1..100
    end
  end

  test "should show courses with provided params" do
    log_in_as(@user)

    get :index, department: departments(:cmpt)
    assert_template :index
    assert_select 'select.department_select' do
      assert_select 'option', range: 2..100
    end
    assert_select 'tbody#course_list' do
      assert_select 'tr', range: 1..100
    end
  end

  test "get_courses" do
    log_in_as(@user)

    get :index
    assert_template :index
    get :get_courses, xhr: true, format: :js, department_id: departments(:cmpt).id
    assert_response :success
  end

  test "should redirect on invalid course" do
    log_in_as(@user)

    get :info, id: ''
    assert_response :redirect
    assert_redirected_to courses_path
    assert_not flash.empty?
    assert flash[:danger]
  end

  test "should redirect on course not enrolled in" do
    log_in_as(@superuser)

    get :show, id: @coursetwo.id
    assert_response :redirect
    assert_redirected_to get_info_course_path(@coursetwo)
    assert_not flash.empty?
    assert flash[:warning]
  end

  test "should allow to course chat if enrolled" do
    log_in_as(@superuser)

    get :show, id: @course.id
    assert_response :success
    assert_template :show
    assert flash.empty?
  end

end
