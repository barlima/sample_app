require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @admin = users(:michael)
    @non_admin = users(:archer)
    @activated_user = users(:michael)
    @non_activated_user = users(:malory)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
      if user.activated?
        assert_select 'a[href=?]', user_path(user), text: user.name
      end
    end
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      if user.activated?
        assert_select 'a[href=?]', user_path(user), text: user.name
        unless user == @admin
          assert_select 'a[href=?]', user_path(user), text: 'delete'
        end
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test 'index should not containt non-activated users' do
    log_in_as(@activated_user)
    get users_path
    assert_template 'users/index'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do
      assert_select 'a[href=?]', user_path(@non_activated_user), text: @non_activated_user.name, count: 0
    end
  end

end
