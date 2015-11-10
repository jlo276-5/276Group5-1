require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = events(:one)
    @user = users(:michael)
  end

  test "should get index" do
    log_in_as(@user)
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get new" do
    log_in_as(@user)
    get :new
    assert_response :success
  end

  test "should create event" do
    log_in_as(@user)

    assert_difference('Event.count') do
      post :create, event: { description: @event.description, end_time: @event.end_time, strat_time: @event.strat_time, title: @event.title }
    end

    assert_redirected_to event_path(assigns(:event))
  end

  test "should show event" do
    log_in_as(@user)

    get :show, id: @event
    assert_response :success
  end

  test "should get edit" do
    log_in_as(@user)

    get :edit, id: @event
    assert_response :success
  end

  test "should update event" do
    log_in_as(@user)

    patch :update, id: @event, event: { description: @event.description, end_time: @event.end_time, strat_time: @event.strat_time, title: @event.title }
    assert_redirected_to event_path(assigns(:event))
  end

  test "should destroy event" do
    log_in_as(@user)

    assert_difference('Event.count', -1) do
      delete :destroy, id: @event
    end

    assert_redirected_to events_path
  end
end
