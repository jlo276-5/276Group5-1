require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @standard = users(:lana)
    @admin = users(:michael)
    @super = users(:superman)
  end

  test "index including pagination" do
    log_in_as(@standard)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1, per_page: 25).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1, per_page: 25)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      if (user != @admin and @admin.more_powerful(true, user))
        assert_select 'a[href=?]', user_path(user), text: 'Delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@standard)
    end
  end

  test "index as super including pagination and delete links" do
    log_in_as(@super)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1, per_page: 25)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      if (user != @super and @super.more_powerful(true, user))
        assert_select 'a[href=?]', user_path(user), text: 'Delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@standard)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
