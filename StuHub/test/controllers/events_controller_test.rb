require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = events(:one)
    @user = users(:superman)
    @otheruser = users(:archer)
  end

  test "should redirect html index" do
    log_in_as(@user)
    get :index, xhr: true
    assert_response :redirect
  end

  test "should get new" do
    log_in_as(@user)
    get :new
    assert_response :success
  end

  test "should create event" do
    log_in_as(@user)

    assert_difference('Event.count') do
      post :create, event: { description: @event.description, end_time: @event.end_time+10.minutes, start_time: @event.start_time, end_date: @event.end_date+1.day, start_date: @event.start_date, title: @event.title, dow: [] }
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should show event" do
    log_in_as(@user)

    get :show, id: @event.id
    assert_response :success
  end

  test "should get edit" do
    log_in_as(@user)

    get :edit, id: @event.id
    assert_response :success
  end

  test "should redirect edit if not creator" do
    log_in_as(@otheruser)
    get :edit, id: @event.id
    assert_response :redirect
    assert_redirected_to home_path
  end

  test "should update event" do
    log_in_as(@user)

    patch :update, id: @event, event: { description: @event.description, end_time: @event.end_time, start_time: @event.start_time, title: @event.title, dow: [] }
    assert_response :redirect
    assert_redirected_to @event
  end

  test "should redirect update if not creator" do
    log_in_as(@otheruser)
    patch :update, id: @event.id, event: { description: @event.description, end_time: @event.end_time, start_time: @event.start_time, title: @event.title, dow: [] }
    assert_response :redirect
    assert_redirected_to home_path
  end

  test "should destroy event" do
    log_in_as(@user)

    assert_difference('Event.count', -1) do
      delete :destroy, id: @event.id
    end

    assert_redirected_to events_path
  end

  test "should redirect destroy if not creator" do
    log_in_as(@otheruser)
    delete :destroy, id: @event.id
    assert_response :redirect
    assert_redirected_to home_path
  end
end
