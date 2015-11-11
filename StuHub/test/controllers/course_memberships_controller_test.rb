require 'test_helper'

class CourseMembershipsControllerTest < ActionController::TestCase

  def setup
    @user = users(:archer)
    @superuser = users(:superman)
    @cm = course_memberships(:one)
  end

  test "should redirect when not logged in" do
    post :create
    assert_response :redirect
    assert_redirected_to login_path
  end

  test "should redirect create when already enrolled" do
    log_in_as(@superuser)

    post :create, course_id: @cm.course.id, user_id: @superuser.id
    assert_response :redirect
    assert_redirected_to get_info_course_path(@cm.course)
    assert_not flash.empty?
    assert flash[:warning]
  end

  test "should show join_success if added" do
    log_in_as(@user)

    post :create, course_id: courses(:courseone), user_id: @user.id
    assert_redirected_to join_success_course_membership_path(CourseMembership.last)
  end

  test "should warn if adding section again" do
    log_in_as(@superuser)

    assert_no_difference '@cm.sections.size' do
      post :add_section, id: @cm.id, section_id: sections(:cmptoneone).id
    end
    assert_redirected_to get_info_course_path(@cm.course)
    assert_not flash.empty?
    assert flash[:warning]
  end

  test "should warn if adding not correct course section" do
    log_in_as(@superuser)

    assert_no_difference '@cm.sections.size' do
      post :add_section, id: @cm.id, section_id: sections(:macmoneone).id
    end
    assert_redirected_to courses_path
    assert_not flash.empty?
    assert flash[:danger]
  end

  test "should add section successfully" do
    log_in_as(@superuser)

    assert_difference '@cm.sections.size', 1 do
      post :add_section, id: @cm.id, section_id: sections(:cmptonetwo).id
    end
    assert_redirected_to get_info_course_path(@cm.course)
    assert_not flash.empty?
    assert flash[:success]
  end

  test "should error if removing section not added" do
    log_in_as(@superuser)

    assert_no_difference '@cm.sections.size' do
      post :remove_section, id: @cm.id, section_id: sections(:cmptonetwo).id
    end
    assert_redirected_to get_info_course_path(@cm.course)
    assert_not flash.empty?
    assert flash[:danger]
  end

  test "should error if removing correct section" do
    log_in_as(@superuser)

    assert_difference '@cm.sections.size', -1 do
      post :remove_section, id: @cm.id, section_id: sections(:cmptoneone).id
    end
    assert_redirected_to get_info_course_path(@cm.course)
    assert_not flash.empty?
    assert flash[:success]
  end

  test "should redirect to user after destroy" do
    log_in_as(@superuser)

    delete :destroy, id: @cm.id
    assert_redirected_to @superuser
    assert flash[:success]
  end

end
