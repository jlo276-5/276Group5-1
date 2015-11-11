require 'test_helper'

class MessagesControllerTest < ActionController::TestCase

  def setup
    @super = users(:superman)
    @user = users(:lana)
  end

  test "should redirect message viewer if not admin" do
    log_in_as(@user)

    get :index
    assert_redirected_to home_path
    assert_not flash.empty?
    assert_equal "You do not have the permission to see that.", flash[:danger]
  end

  # test "should create message on valid parameters" do
  #   log_in_as(@super)
  #
  #   get :index
  #   assert_difference 'Message.all.size' do
  #     post :create, xhr: true, format: :js, message: { content: "Hello, world!", user_id: @user.id, channel_type: -1, channel_id: -1 }
  #   end
  #   assert_template :create
  # end

end
